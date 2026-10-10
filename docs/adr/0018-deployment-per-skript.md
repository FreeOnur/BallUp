# 0018 – Deployment per Skript statt GitHub Actions

- **Status:** Akzeptiert
- **Datum:** 2026-10-10

## Kontext

Geplant war `backend-deploy.yml`: GitHub Actions baut das Image, pusht es zu Docker Hub und deployt per
SSH auf einen Git-Checkout unter `/opt/ballup`. Im Projekt SDX Eye deployen wir per Skript vom eigenen
Rechner, das hat sich bewährt: ein Befehl, sofortiges Feedback im Terminal, kein Warten auf CI-Runner und
keine Server-Zugangsdaten in GitHub.

## Entscheidung

Deployt wird per **npm-Skript vom eigenen Rechner** (Windows oder Mac), nicht über GitHub Actions:

1. `push` – Image lokal bauen (`linux/amd64`, passend zum Hetzner-Server) und zu Docker Hub pushen,
   Tags `<commit-sha>` und `latest` (`<sha>-dirty` bei nicht committeten Änderungen in `backend/`).
2. `sync` – `deploy/compose`, `deploy/caddy`, `deploy/observability`, `deploy/scripts/server` per SSH nach
   `/opt/ballup/deploy` kopieren. **Kein Git-Checkout** auf dem Server, kein Deploy-Key nötig.
3. `pull.sh` auf dem Server – `docker compose pull` + `up -d`, wartet auf den Healthcheck der API
   (`/health`), merkt sich das deployte Image in `.api-image`.

Befehle: `npm run deploy:api`, `npm run deploy`, `npm run rollback -- <sha>`, `npm run status`,
`npm run logs`, `npm run ssh`, `npm run install:server`. Ablauf im Detail: [Runbook Deploy](../runbooks/deploy.md).

Der Server-Zugang läuft über den User `deploy` (Gruppe `docker`) mit dem Schlüssel `~/.ssh/ballup_deploy`.
`deploy/scripts/run.mjs` startet die Bash-Skripte unter Windows mit Git Bash (nicht WSL).

## Alternativen

| Option | Warum nicht |
|---|---|
| GitHub Actions → Docker Hub → Server (`backend-deploy.yml`) | Secrets in GitHub, langsamere Rückmeldung, anders als in SDX Eye |
| GitHub Actions baut und schickt das Image direkt per SSH (ohne Docker Hub) | Kein Image-Verlauf für Rollbacks |
| Git-Checkout auf dem Server | Braucht Deploy-Key und sauberen Server-Checkout; wir brauchen dort nur die Deploy-Dateien |

## Konsequenzen

- Positiv: Ein Befehl zum Deployen, Rollback auf jedes frühere Image per SHA, keine Server-Secrets in GitHub.
- Negativ / Aufwand: Wer deployt, braucht Docker, Node, SSH-Schlüssel und Docker-Hub-Login auf seinem Rechner.
  Kein automatischer Deploy bei Merge – Deployen ist ein bewusster Schritt (siehe [Release](../checklists/release.md)).
- Teilweise ersetzt: der Deploy-Ablauf (`backend-deploy.yml`, `git pull` auf dem Server) in
  [0002](0002-deploy-ordner-statt-infra.md).
