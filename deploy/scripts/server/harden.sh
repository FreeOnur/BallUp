#!/usr/bin/env bash
# Einmalige Härtung des BallUp-Servers. Läuft AUF DEM SERVER als onur:
#   sudo bash /opt/ballup/deploy/scripts/server/harden.sh
# Jeder Schritt prüft erst, ob er schon erledigt ist. Das Skript darf also mehrfach laufen.
# Anleitung und Notfall-Zugang: docs/runbooks/server-zugang.md
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Bitte mit sudo starten: sudo bash $0"
  exit 1
fi

ENV_FILE=/opt/ballup/deploy/compose/.env
step() { printf '\n== %s\n' "$1"; }

step "1/6 Alten Umzugs-Schlüssel entfernen"
for f in /root/.ssh/authorized_keys /home/onur/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys; do
  [[ -f ${f} ]] || continue
  if grep -q 'claude-server-umzug' "${f}"; then
    sed -i '/claude-server-umzug/d' "${f}"
    echo "entfernt aus ${f}"
  fi
done
echo "fertig"

step "2/6 Alarme aufs Handy (ntfy)"
if [[ ! -f ${ENV_FILE} ]]; then
  echo "FEHLER: ${ENV_FILE} fehlt"
  exit 1
fi
if grep -q '^NTFY_URL=https://' "${ENV_FILE}"; then
  echo "NTFY_URL ist schon gesetzt"
else
  sed -i '/^NTFY_URL=/d' "${ENV_FILE}"
  echo "NTFY_URL=https://ntfy.sh/ballup-$(openssl rand -hex 12)" >> "${ENV_FILE}"
  echo "NTFY_URL angelegt"
fi
ntfy_url="$(grep '^NTFY_URL=' "${ENV_FILE}" | cut -d= -f2-)"
echo "In der ntfy-App auf dem Handy dieses Thema abonnieren (geheim halten):"
echo "    ${ntfy_url#https://ntfy.sh/}"
if curl -fsS -H "Title: BallUp" -d "Test: Alarme vom Server kommen an." "${ntfy_url}" >/dev/null; then
  echo "Testnachricht geschickt"
fi

step "3/6 Tailscale"
if ! command -v tailscale >/dev/null 2>&1; then
  curl -fsSL https://tailscale.com/install.sh | sh
fi
if tailscale ip -4 >/dev/null 2>&1; then
  echo "Tailscale läuft schon"
else
  echo "Gleich erscheint ein Link. Im Browser öffnen und mit dem BallUp-Google-Konto anmelden."
  tailscale up --hostname=ballup-server
fi
echo "Tailscale-Adresse: $(tailscale ip -4)"

step "4/6 sudo nur noch mit Passwort"
mapfile -t nopasswd_files < <(grep -lE '^[[:space:]]*onur[[:space:]].*NOPASSWD' /etc/sudoers.d/* 2>/dev/null || true)
if grep -qE '^[[:space:]]*onur[[:space:]].*NOPASSWD' /etc/sudoers; then
  echo "NOPASSWD für onur steht in /etc/sudoers. Bitte mit 'sudo visudo' von Hand entfernen."
fi
if [[ ${#nopasswd_files[@]} -eq 0 ]]; then
  echo "onur braucht schon ein Passwort für sudo"
else
  echo "Jetzt ein Passwort für onur festlegen. Vorher in Bitwarden erzeugen (mindestens 20 Zeichen) und speichern."
  echo "Es gilt für sudo und für die Hetzner-Konsole, nicht für SSH (SSH bleibt nur mit Schlüssel)."
  passwd onur
  for f in "${nopasswd_files[@]}"; do
    cp -p "${f}" "/root/$(basename "${f}").vor-harden"
    sed -E 's/^([[:space:]]*onur[[:space:]].*)NOPASSWD:[[:space:]]*/\1/' "${f}" > "${f}.neu"
    if visudo -cf "${f}.neu" >/dev/null; then
      chmod 440 "${f}.neu"
      mv "${f}.neu" "${f}"
      echo "geändert: ${f} (Sicherung in /root/)"
    else
      rm -f "${f}.neu"
      echo "FEHLER: ${f} nicht geändert, sudo bleibt wie bisher"
    fi
  done
fi

step "5/6 System-Logs begrenzen"
journald_conf=/etc/systemd/journald.conf.d/ballup.conf
if [[ -f ${journald_conf} ]]; then
  echo "schon begrenzt"
else
  mkdir -p "$(dirname "${journald_conf}")"
  printf '[Journal]\nSystemMaxUse=300M\nMaxRetentionSec=1month\n' > "${journald_conf}"
  systemctl restart systemd-journald
  journalctl --vacuum-size=300M >/dev/null
  echo "Journal auf 300 MB und 1 Monat begrenzt"
fi

step "6/6 Speicher und Platte"
docker stats --no-stream --format 'table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}'
echo
free -h
df -h /
echo
echo "Größte Ordner auf der Platte:"
du -xh --max-depth=2 / 2>/dev/null | sort -h | tail -12
echo
docker system df

printf '\nFertig. Als Nächstes: docs/runbooks/server-zugang.md, Abschnitt "Port 22 schließen".\n'
