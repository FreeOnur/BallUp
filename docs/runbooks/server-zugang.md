# Runbook: Server-Zugang, Alarme und Härtung

> Schritt-für-Schritt-Anleitung für den Betrieb (Deploy, Rollback, Backup-Restore, Incident …).
> So schreiben, dass es nachts um 3 Uhr ohne Vorwissen funktioniert.

- **Wann nutzen:** Server einmalig härten, SSH auf Tailscale umstellen, Alarme aufs Handy einrichten,
  oder wenn man nicht mehr auf den Server kommt
- **Dauer:** ca. 30 Minuten beim ersten Mal
- **Braucht:** Admin-Zugang als `onur` (Schlüssel `privat_server`), Bitwarden, Handy mit der App **ntfy**,
  Zugang zur Hetzner Console

## Wie der Server erreichbar ist

| Was | Wie |
|---|---|
| API, Website, Statusseite | öffentlich über Caddy (80/443) |
| SSH (`onur`, `deploy`) | Ziel: nur über Tailscale als `ballup-server`. Port 22 ist in der Hetzner-Firewall zu. |
| Grafana | nur per Tunnel: `npm run tunnel:grafana`, dann `http://localhost:3000` |
| Uptime-Kuma-Admin | nur per Tunnel: `npm run tunnel:status`, dann `http://localhost:3001` |
| `sudo` für `onur` | nur mit Passwort (steht in Bitwarden: „BallUp Server – onur sudo“) |

## Schritte

### 1. Tailscale auf dem eigenen Rechner

1. Tailscale installieren: https://tailscale.com/download
2. Mit dem **BallUp-Google-Konto** (`@ballup.eu`) anmelden, nicht mit einem privaten Konto.
3. In der Tailscale-Admin-Seite **MagicDNS** an lassen (Standard).

### 2. Härtungs-Skript auf dem Server

1. Im Repo-Root `npm run sync` (kopiert das Skript auf den Server, startet nichts neu).
2. Als `onur` auf den Server (ServerDeck oder `ssh -i ~/.ssh/privat_server onur@ballup-server`, vor der Umstellung `onur@46.224.171.6`).
3. `sudo bash /opt/ballup/deploy/scripts/server/harden.sh`
4. Das Skript:
   - entfernt den alten Umzugs-Schlüssel,
   - legt `NTFY_URL` in `.env` an und schickt eine Testnachricht. Das ausgegebene Thema in der ntfy-App abonnieren.
   - installiert Tailscale. Den angezeigten Link öffnen und mit dem BallUp-Konto bestätigen.
   - fragt nach einem Passwort für `onur`. Vorher in Bitwarden erzeugen und speichern.
     Danach braucht `sudo` dieses Passwort.
   - zeigt `docker stats`, RAM und Platte.
5. Zurück auf dem eigenen Rechner: `npm run deploy` (startet node-exporter, die Grafana-Alarme
   und Grafana ohne öffentliche Domain).

### 3. Uptime Kuma: Alarme aufs Handy

1. `npm run tunnel:status`, `http://localhost:3001` öffnen und anmelden.
2. **Einstellungen → Benachrichtigungen → Einrichten**: Typ **ntfy**, Server `https://ntfy.sh`,
   Thema wie in `NTFY_URL` (ohne `https://ntfy.sh/`), Priorität 5,
   „Standardmäßig aktiviert“ und „Auf alle bestehenden Monitore anwenden“ anhaken. Testen, speichern.
3. **Einstellungen → Benachrichtigungen → TLS-Zertifikatsablauf**: 14 Tage eintragen.
4. Monitore (Typ HTTP(s), Intervall 60 s, „Zertifikatsablauf-Benachrichtigung“ an):
   - `https://api.ballup.eu/health`
   - `https://ballup.eu`
   - `https://status.ballup.eu/status/ballup`

### 4. Port 22 schließen

Erst, wenn das hier vom eigenen Rechner aus klappt:

```bash
BALLUP_HOST=ballup-server npm run status
ssh -i ~/.ssh/privat_server onur@ballup-server
```

1. Die Skripte nutzen seit dem 07.11.2026 standardmäßig `ballup-server` (`BALLUP_HOST` in
   `deploy/scripts/deploy/config.sh`). ServerDeck ebenfalls auf `ballup-server` umstellen.
   In der Tailscale-Admin-Seite bei `ballup-server` **Disable key expiry**, sonst fliegt der Server nach 180 Tagen raus.
2. Hetzner Console → **Firewalls** → `ballup-firewall` → Regel für **TCP 22** löschen.
3. Prüfen: `ssh onur@46.224.171.6` läuft ins Leere (Timeout), `npm run status` geht weiter.

## Prüfen, ob es geklappt hat

- In der ntfy-App ist die Testnachricht angekommen.
- `npm run tunnel:grafana` → Grafana → **Alerting → Alert rules**: „Platte über 80 %“ und „RAM über 85 %“ sind grün (Normal).
- `https://grafana.ballup.eu` ist nicht mehr erreichbar. Den DNS-Eintrag `grafana` in der Hetzner Console löschen.
- `sudo -k && sudo true` fragt nach dem Passwort.

## Wenn es schiefgeht

- **`Could not resolve hostname ballup-server`:** Tailscale auf dem eigenen Rechner ist aus oder abgemeldet.
  Tailscale-Symbol in der Taskleiste → Connected mit dem BallUp-Konto.
- **Tailscale geht nicht und Port 22 ist zu:** Hetzner Console → Server → **Konsole** (`>_`), als `onur`
  mit dem Passwort aus Bitwarden anmelden (oder `root` mit dem Root-Passwort). `sudo tailscale up` neu.
  Notfalls in der Firewall die Regel TCP 22 kurz wieder anlegen und danach wieder löschen.
- **sudo-Passwort vergessen:** in der Hetzner-Konsole als `root` anmelden, `passwd onur`.
  Die alte sudo-Regel liegt als Sicherung unter `/root/*.vor-harden`.
- **`set NTFY_URL in .env`:** Schritt 2 wurde noch nicht ausgeführt.
- **Grafana startet nicht nach dem Deploy:** `npm run logs` und nach `provisioning` suchen.
  Meist ist `NTFY_URL` leer oder ohne `https://`.
- **Zu viele Alarme:** in Grafana unter Alerting → Silences stummschalten, dann den Schwellwert in
  `deploy/observability/grafana/provisioning/alerting/alerts.yml` anpassen.
