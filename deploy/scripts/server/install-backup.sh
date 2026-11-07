#!/usr/bin/env bash
# Richtet das nächtliche DB-Backup ein oder aktualisiert es. Läuft AUF DEM SERVER als onur:
#   sudo bash /opt/ballup/deploy/scripts/server/install-backup.sh
# Jeder Schritt prüft erst, ob er schon erledigt ist. Das Skript darf also mehrfach laufen,
# z. B. nach jeder Änderung an backup-db.sh (vorher npm run sync).
# Anleitung: docs/runbooks/restore.md
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Bitte mit sudo starten: sudo bash $0"
  exit 1
fi

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE=/opt/ballup/deploy/compose/.env
SCRIPT_DEST=/usr/local/sbin/ballup-db-backup
UNIT_DIR=/etc/systemd/system
step() { printf '\n== %s\n' "$1"; }

# Kopiert nur, wenn sich der Inhalt geändert hat. Gibt 0 zurück, wenn kopiert wurde.
install_if_changed() {
  local src="$1" dest="$2" mode="$3"
  if [[ -f ${dest} ]] && cmp -s "${src}" "${dest}"; then
    echo "unverändert: ${dest}"
    return 1
  fi
  if [[ -f ${dest} && ! -f /root/$(basename "${dest}").vor-install ]]; then
    cp -p "${dest}" "/root/$(basename "${dest}").vor-install"
    echo "Sicherung der alten Version: /root/$(basename "${dest}").vor-install"
  fi
  install -o root -g root -m "${mode}" "${src}" "${dest}.neu"
  mv -f "${dest}.neu" "${dest}"
  echo "installiert: ${dest}"
}

step "1/5 Backup-Skript"
install_if_changed "${SRC_DIR}/backup-db.sh" "${SCRIPT_DEST}" 750 || true
bash -n "${SCRIPT_DEST}"

step "2/5 systemd-Service und -Timer"
# Erst die neuen Dateien prüfen, dann installieren. So bleibt bei einem Fehler alles beim Alten.
systemd-analyze verify "${SRC_DIR}/systemd/ballup-db-backup.service" "${SRC_DIR}/systemd/ballup-db-backup.timer"
changed=0
for unit in ballup-db-backup.service ballup-db-backup.timer; do
  if install_if_changed "${SRC_DIR}/systemd/${unit}" "${UNIT_DIR}/${unit}" 644; then
    changed=1
  fi
done
if [[ ${changed} -eq 1 ]]; then
  systemctl daemon-reload
fi
systemctl enable --now ballup-db-backup.timer
if [[ ${changed} -eq 1 ]]; then
  systemctl restart ballup-db-backup.timer
fi
systemctl list-timers --no-pager ballup-db-backup.timer

step "3/5 Alte Cron-Jobs für das Backup"
found=0
for f in /etc/crontab /etc/cron.d/* /etc/cron.daily/*; do
  [[ -f ${f} ]] || continue
  if grep -qE 'pg_dump|ballup-db-backup|/var/backups/ballup' "${f}"; then
    found=1
    if [[ ${f} == /etc/crontab ]]; then
      echo "In /etc/crontab steht noch ein Backup-Job. Bitte mit 'sudo nano /etc/crontab' entfernen."
    else
      mv "${f}" "/root/$(basename "${f}").cron-vor-install"
      echo "abgelöst: ${f} (verschoben nach /root/)"
    fi
  fi
done
for u in root onur deploy; do
  if crontab -l -u "${u}" 2>/dev/null | grep -vE '^[[:space:]]*#' | grep -qE 'pg_dump|ballup-db-backup'; then
    found=1
    echo "Die Crontab von ${u} enthält noch einen Backup-Job. Bitte mit 'sudo crontab -e -u ${u}' entfernen."
  fi
done
[[ ${found} -eq 0 ]] && echo "keine gefunden"

step "4/5 Einstellungen in .env"
for key in NTFY_URL BACKUP_PUSH_URL; do
  if grep -qE "^${key}=.+" "${ENV_FILE}" 2>/dev/null; then
    echo "${key} ist gesetzt"
  else
    echo "FEHLT: ${key} in ${ENV_FILE} (siehe .env.example und docs/runbooks/restore.md)"
  fi
done

step "5/5 Vorhandene Dumps"
# shellcheck disable=SC2012 # nur Anzeige
ls -la --time-style=long-iso /var/backups/ballup 2>/dev/null | tail -n 5 || echo "noch keine"

cat <<'EOF'

Fertig. Testlauf:
  sudo systemctl start ballup-db-backup.service && sudo journalctl -u ballup-db-backup -n 20 --no-pager
  sudo /usr/local/sbin/ballup-db-backup --fehlertest   # muss einen ntfy-Alarm schicken
EOF
