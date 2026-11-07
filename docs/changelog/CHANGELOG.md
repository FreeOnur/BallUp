# Changelog

Was sich am Produkt und am Gerüst geändert hat, neueste Zeile oben. Ein Eintrag pro gemergtem PR, der den Stand verschiebt.

Dependabot-Bumps und reine Formatierung stehen hier nicht. Die stehen in `git log`. Keine Secrets, keine Roh-Logs, keine Tokens.

## 2026-11-07

- Deploy-Skripte gehen über Tailscale (`ballup-server`), Port 22 ist von außen zu. Grafana darf 512 MB nutzen. `harden.sh` begrenzt das System-Journal auf 300 MB und zeigt die größten Ordner.

- Alarme aufs Handy über ntfy: Grafana meldet Platte über 80 % und RAM über 85 % (neuer Dienst node-exporter), Uptime Kuma meldet Ausfälle und ablaufende Zertifikate.
- Grafana ist nicht mehr öffentlich (`grafana.ballup.eu` entfällt), nur noch per `npm run tunnel:grafana`.
- Jeder Deploy löscht ungenutzte Docker-Images, die älter als 7 Tage sind.
- `deploy/scripts/server/harden.sh` und Runbook `server-zugang.md`: Tailscale, `sudo` mit Passwort, alter Umzugs-Schlüssel entfernt. Die Server-Adresse der Deploy-Skripte ist über `BALLUP_HOST` einstellbar.

## 2026-11-06

- Container gehärtet: `no-new-privileges` und ein Speicherlimit für jeden Dienst in `compose.yml` und `compose.observability.yml`. Die API nimmt höchstens 10 MB pro Request an (Caddy).

## 2026-11-04

- `ballup.eu` mit HTTPS: Platzhalterseite und `/.well-known/` für Android App Links und iOS Universal Links (`deploy/site/`). `www.ballup.eu` leitet auf `ballup.eu` um.

## 2026-10-24

- Founder-Recherche aus dem Repo genommen. Die Dateien liegen im Google Drive, `founder/` steht in `.gitignore`.
- App-ID von `app.ballup` auf `eu.ballup` (Android, iOS, Kotlin-Pakete). ADR 0019.
- Release-Checkliste auf Deploy per npm-Skript. Launch-Preis 4,99 €/Monat.
- Postgres 18 + PostGIS und Alembic. Erste Migration ohne Fach-Tabellen. `/docs` in Produktion aus.
- Backend-Module nach ADR 0009 in Singular-Ordner gelegt, `repository.py` entfernt, `core/` als Basis.
