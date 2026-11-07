#!/usr/bin/env bash
# Monatlicher Restore-Test. Läuft AUF DEM SERVER:
#   sudo bash /opt/ballup/deploy/scripts/server/restore-test-db.sh [dump-datei]
# Spielt den neuesten Dump (oder den angegebenen) in einen Wegwerf-PostGIS-Container ohne Netzwerk ein,
# zählt Tabellen und Zeilen und löscht den Container wieder. Die Live-Datenbank wird nicht angefasst.
# Anleitung: docs/runbooks/restore.md
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/var/backups/ballup}"
COMPOSE_DIR="${BACKUP_COMPOSE_DIR:-/opt/ballup/deploy/compose}"

[[ ${EUID} -eq 0 ]] || { echo "Bitte mit sudo starten: sudo bash $0"; exit 1; }

dump="${1:-}"
if [[ -z ${dump} ]]; then
  dump="$(find "${BACKUP_DIR}" -maxdepth 1 -type f -name 'ballup-*.dump' -printf '%T@ %p\n' \
    | sort -n | tail -n 1 | cut -d' ' -f2-)"
fi
[[ -n ${dump} && -f ${dump} ]] || { echo "FEHLER: kein Dump gefunden in ${BACKUP_DIR}"; exit 1; }

# Dasselbe Image wie in Produktion (aus compose.yml), sonst der Standard.
image="$(grep -m1 -oE 'image: *postgis/postgis:[^ ]+' "${COMPOSE_DIR}/compose.yml" 2>/dev/null | sed 's/image: *//' || true)"
image="${RESTORE_IMAGE:-${image:-postgis/postgis:18-3.6}}"
name="ballup-restore-test-$$"
started="$(date +%s)"

cleanup() { docker rm -f "${name}" >/dev/null 2>&1 || true; }
trap cleanup EXIT

echo "Dump:      ${dump} ($(du -h "${dump}" | cut -f1), $(date -r "${dump}" '+%F %H:%M'))"
echo "Image:     ${image}"
echo "Container: ${name} (ohne Netzwerk, wird danach gelöscht)"

docker run -d --name "${name}" --network none --memory 768m \
  -e POSTGRES_PASSWORD="$(openssl rand -hex 16)" \
  "${image}" >/dev/null

# Über TCP prüfen: Der Init-Server beim ersten Start hört nur auf den Socket und startet danach neu.
for attempt in $(seq 1 60); do
  if docker exec "${name}" pg_isready -q -h 127.0.0.1 -U postgres 2>/dev/null; then
    break
  fi
  if [[ ${attempt} -eq 60 ]]; then
    echo "FEHLER: Wegwerf-Postgres startet nicht"; docker logs --tail 30 "${name}"; exit 1
  fi
  sleep 2
done

psql_q() { docker exec -i "${name}" psql -U postgres -d restore -v ON_ERROR_STOP=1 -Atq "$@"; }

docker exec "${name}" createdb -U postgres -T template0 restore
echo "Spiele Dump ein ..."
if ! docker exec -i "${name}" pg_restore -U postgres -d restore --no-owner --no-acl --exit-on-error < "${dump}"; then
  echo "RESTORE-TEST FEHLGESCHLAGEN: pg_restore hat abgebrochen (Ausgabe oben)"
  exit 1
fi

echo
echo "Tabellen und Zeilen der App (ohne Tabellen von PostGIS selbst):"
counts="$(psql_q -F $'\t' <<'SQL'
SELECT n.nspname || '.' || c.relname,
       (xpath('/row/c/text()',
              query_to_xml(format('SELECT count(*) AS c FROM %I.%I', n.nspname, c.relname), false, true, '')))[1]::text::bigint
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'p')
  AND n.nspname NOT IN ('pg_catalog', 'information_schema', 'tiger', 'tiger_data', 'topology')
  AND n.nspname NOT LIKE 'pg_toast%'
  AND NOT EXISTS (SELECT 1 FROM pg_depend d WHERE d.objid = c.oid AND d.deptype = 'e')
ORDER BY 1;
SQL
)"
printf '%s\n' "${counts}" | awk -F'\t' '{ printf "  %-40s %10s\n", $1, $2 }'
tables="$(printf '%s\n' "${counts}" | grep -c . || true)"
rows="$(printf '%s\n' "${counts}" | awk -F'\t' '{ s += $2 } END { print s + 0 }')"
version="$(psql_q -c 'SELECT version_num FROM public.alembic_version' 2>/dev/null || echo '?')"

echo
echo "RESTORE-TEST OK: ${tables} Tabellen, ${rows} Zeilen, Alembic-Version ${version:-leer}, Dauer $(( $(date +%s) - started )) s"
