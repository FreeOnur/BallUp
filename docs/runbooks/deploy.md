# Runbook: Backend deployen und zurückrollen

> Schritt-für-Schritt-Anleitung für den Betrieb (Deploy, Rollback, Backup-Restore, Incident …).
> So schreiben, dass es nachts um 3 Uhr ohne Vorwissen funktioniert.

- **Wann nutzen:** neue Backend-Version live bringen, Konfiguration auf dem Server ändern, zurückrollen
- **Dauer:** ca. 3–5 Minuten
- **Braucht:** Docker (läuft), Node, Git (unter Windows: Git for Windows), SSH-Schlüssel `~/.ssh/ballup_deploy`,
  `docker login -u onurballup` auf dem eigenen Rechner. Hintergrund: [ADR 0018](../adr/0018-deployment-per-skript.md)

Server: `deploy@46.224.171.6`, Dateien unter `/opt/ballup/deploy`, Konfiguration in `/opt/ballup/deploy/compose/.env`.

## Befehle (im Repo-Root)

| Befehl | Was passiert |
|---|---|
| `npm run deploy:api` | Image bauen + pushen, Deploy-Dateien kopieren, nur API neu starten |
| `npm run deploy` | wie oben, aber der ganze Stack (Caddy, Redis, Grafana, Prometheus, Tempo, Uptime Kuma) |
| `npm run rollback -- <sha>` | API auf ein früheres Image zurücksetzen, ohne Build |
| `npm run status` | Container, deployte Version, Health der API |
| `npm run logs` / `npm run logs:api` | Logs live verfolgen (Strg+C beendet) |
| `npm run ssh` | Shell auf dem Server im Compose-Ordner, z. B. um `.env` zu bearbeiten |
| `npm run sync` | nur Deploy-Dateien kopieren (z. B. nach Änderung an Caddyfile), danach `npm run deploy` |
| `npm run install:server` | Ersteinrichtung: Dateien kopieren, `.env` aus `.env.example` anlegen |

## Schritte

1. Auf dem Stand sein, der live gehen soll (in der Regel `main` nach dem Merge), `git status` sauber.
   Sonst bekommt das Image das Tag `<sha>-dirty`.
2. Docker Desktop starten.
3. `npm run deploy:api`
4. Am Ende muss `api healthy (...)` und `deploy done` stehen.

## Prüfen, ob es geklappt hat

- `npm run status` zeigt die API mit `healthy` und das Image mit dem erwarteten SHA.
- `https://<API_DOMAIN>/health` liefert `{"status":"ok"}`.

## Wenn es schiefgeht

- **`ERROR: api is unhealthy`** – das Skript zeigt die letzten Logs. Sofort zurückrollen:
  `npm run rollback -- <letzter funktionierender sha>` (Tags siehe Docker Hub `onurballup/ballup-api`).
- **`.env not found`** – `npm run install:server`, dann `.env` ausfüllen (`npm run ssh`, `nano .env`).
- **`set XYZ in .env`** – ein Pflichtwert in `.env` fehlt.
- **`push access denied`** – lokal `docker login -u onurballup` (Access Token mit Read & Write).
- **`failed to connect to the docker API`** – Docker Desktop läuft nicht.
- **`Permission denied (publickey)`** – Schlüssel `~/.ssh/ballup_deploy` fehlt auf diesem Rechner
  (vom anderen Rechner kopieren oder neuen Schlüssel in `/home/deploy/.ssh/authorized_keys` eintragen).
