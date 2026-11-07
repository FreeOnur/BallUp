#!/usr/bin/env bash
# Nächtliches Backup der BallUp-Datenbank. Läuft AUF DEM SERVER als root, gestartet vom
# systemd-Timer ballup-db-backup.timer (03:30 Wiener Zeit). Installiert wird es mit install-backup.sh.
#   sudo /usr/local/sbin/ballup-db-backup               – Backup jetzt machen
#   sudo /usr/local/sbin/ballup-db-backup --fehlertest  – absichtlich scheitern, prüft den ntfy-Alarm
#
# Ablauf: pg_dump -Fc → prüfen (pg_restore --list, Größe gegen den letzten guten Dump) →
# Push an Uptime Kuma (BACKUP_PUSH_URL) → alte Dumps löschen. Jeder Fehler schickt einen
# Alarm an NTFY_URL und endet mit Exit-Code 1. Restore: docs/runbooks/restore.md
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/var/backups/ballup}"
COMPOSE_DIR="${BACKUP_COMPOSE_DIR:-/opt/ballup/deploy/compose}"
ENV_FILE="${BACKUP_ENV_FILE:-${COMPOSE_DIR}/.env}"
KEEP_DAYS="${BACKUP_KEEP_DAYS:-14}"
# Ein neuer Dump, der kleiner ist als MIN_PERCENT % des letzten guten, gilt als kaputt.
MIN_PERCENT="${BACKUP_MIN_PERCENT:-50}"
LOCK_FILE="${BACKUP_LOCK_FILE:-/run/ballup-db-backup.lock}"

log() { printf '%s\n' "$*"; }

# Einzelnen Wert aus der .env lesen, ohne die ganze Datei zu laden (Werte können Sonderzeichen haben).
env_value() {
  [[ -r ${ENV_FILE} ]] || return 0
  grep -E "^$1=" "${ENV_FILE}" | tail -n 1 | cut -d= -f2- | sed -E 's/^"(.*)"$/\1/; s/^'\''(.*)'\''$/\1/' || true
}

NTFY_URL="$(env_value NTFY_URL)"
PUSH_URL="$(env_value BACKUP_PUSH_URL)"
TMP_FILE=""

alarm() {
  local reason="$1"
  log "FEHLER: ${reason}"
  if [[ -n ${NTFY_URL} ]]; then
    curl -fsS -m 20 \
      -H "Title: BallUp DB-Backup fehlgeschlagen" \
      -H "Priority: high" \
      -H "Tags: rotating_light" \
      -d "$(hostname): ${reason}. Details: journalctl -u ballup-db-backup" \
      "${NTFY_URL}" >/dev/null || log "WARNUNG: ntfy-Alarm konnte nicht gesendet werden"
  else
    log "WARNUNG: NTFY_URL fehlt in ${ENV_FILE}, kein Alarm aufs Handy"
  fi
}

fail() {
  alarm "$1"
  [[ -n ${TMP_FILE} ]] && rm -f "${TMP_FILE}"
  exit 1
}

# Unerwartete Fehler (set -e) sollen auch einen Alarm auslösen.
trap 'fail "unerwarteter Fehler in Zeile ${LINENO}"' ERR

if [[ ${1:-} == "--fehlertest" ]]; then
  fail "Fehlertest (absichtlich ausgelöst, alles in Ordnung)"
fi

[[ ${EUID} -eq 0 ]] || { echo "Bitte als root starten (sudo)."; exit 1; }
[[ -f ${ENV_FILE} ]] || fail "${ENV_FILE} fehlt"

# Nie zwei Backups gleichzeitig.
exec 9>"${LOCK_FILE}"
flock -n 9 || fail "ein anderes Backup läuft noch"

umask 077
mkdir -p "${BACKUP_DIR}"
chmod 700 "${BACKUP_DIR}"

dc() {
  docker compose --project-directory "${COMPOSE_DIR}" -f "${COMPOSE_DIR}/compose.yml" "$@"
}

# Letzter guter Dump = neueste Datei ballup-*.dump (verdächtige heißen *.dump.verdacht).
last_good() {
  find "${BACKUP_DIR}" -maxdepth 1 -type f -name 'ballup-*.dump' -printf '%T@ %p\n' \
    | sort -n | tail -n 1 | cut -d' ' -f2-
}

stamp="$(date +%F-%H%M)"
target="${BACKUP_DIR}/ballup-${stamp}.dump"
TMP_FILE="${target}.tmp"
previous="$(last_good)"

log "Dump nach ${target} ..."
# shellcheck disable=SC2016 # $POSTGRES_* soll erst im Container aufgelöst werden.
if ! dc exec -T postgres sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc' > "${TMP_FILE}"; then
  fail "pg_dump fehlgeschlagen (läuft der Container postgres?)"
fi
[[ -s ${TMP_FILE} ]] || fail "Dump ist leer"

# Prüfung 1: Archiv ist lesbar und enthält die App-Datenbank.
if ! toc="$(dc exec -T postgres pg_restore --list < "${TMP_FILE}")"; then
  fail "pg_restore --list kann den Dump nicht lesen"
fi
grep -q 'TABLE DATA public alembic_version' <<<"${toc}" \
  || fail "Dump enthält keine Tabelle alembic_version (falsche Datenbank?)"
entries="$(grep -cv '^;' <<<"${toc}" || true)"

# Prüfung 2: nicht viel kleiner als der letzte gute Dump.
size="$(stat -c %s "${TMP_FILE}")"
if [[ -n ${previous} ]]; then
  prev_size="$(stat -c %s "${previous}")"
  if (( size * 100 < prev_size * MIN_PERCENT )); then
    mv "${TMP_FILE}" "${target}.verdacht"
    TMP_FILE=""
    fail "Dump nur ${size} Bytes, der letzte gute hatte ${prev_size} (unter ${MIN_PERCENT} %). Behalten als ${target}.verdacht"
  fi
fi

chmod 600 "${TMP_FILE}"
mv "${TMP_FILE}" "${target}"
TMP_FILE=""
log "ok: ${target} (${size} Bytes, ${entries} Einträge)"

# Alte Dumps löschen, den neuesten guten aber nie.
newest="$(last_good)"
while IFS= read -r old; do
  [[ ${old} == "${newest}" ]] && continue
  rm -f -- "${old}"
  log "gelöscht: ${old}"
done < <(find "${BACKUP_DIR}" -maxdepth 1 -type f \( -name 'ballup-*.dump' -o -name 'ballup-*.dump.verdacht' \) -mtime "+${KEEP_DAYS}")

# Erfolg an Uptime Kuma melden. Bleibt der Push aus, schlägt Kuma nach 25 h selbst Alarm.
if [[ -n ${PUSH_URL} ]]; then
  if curl -fsS -m 20 -o /dev/null "${PUSH_URL}"; then
    log "Push an Uptime Kuma gesendet"
  else
    log "WARNUNG: Push an Uptime Kuma fehlgeschlagen (BACKUP_PUSH_URL prüfen)"
  fi
else
  log "WARNUNG: BACKUP_PUSH_URL fehlt in ${ENV_FILE}, kein Push an Uptime Kuma"
fi
