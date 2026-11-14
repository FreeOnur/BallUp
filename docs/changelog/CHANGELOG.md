# Changelog

Was sich am Produkt und am Gerüst geändert hat, neueste Zeile oben. Ein Eintrag pro gemergtem PR, der den Stand verschiebt.

Dependabot-Bumps und reine Formatierung stehen hier nicht. Die stehen in `git log`. Keine Secrets, keine Roh-Logs, keine Tokens.

## 2026-11-13

- Planning in English: master checklist (`docs/checklists/master-checklist.md`), roadmap with 2-week sprints (`docs/roadmap.md`), workflow (`docs/guides/workflow.md`), testing strategy (`docs/guides/testing.md`), issue templates. ADR 0022: website goes to `web/`. Labels renamed to English (`area:*`, `question-for-onur`, `idea`, `status-report`), new `sprint:<n>` labels.

## 2026-11-12

- Force-Update-Middleware im Backend (`core/app_version.py`): liest `X-App-Version` und `X-App-Platform`, antwortet mit `426` und Code `app_version_too_old`, wenn die App unter der Mindestversion liegt. Mindestversion über `BALLUP_MIN_APP_VERSION_IOS` und `BALLUP_MIN_APP_VERSION_ANDROID`, leer = keine Sperre. Ohne Header und für `/health` und `/docs` gibt es keine Sperre. PR [#202](https://github.com/FreeOnur/ballup/pull/202).

## 2026-11-07

- Geprüftes DB-Backup: `deploy/scripts/server/backup-db.sh` testet jeden Dump (`pg_restore --list`, Größe gegen den Vortag), meldet Erfolg per Push an Uptime Kuma und Fehler per ntfy. Der Timer läuft um 03:30 Wiener Zeit statt UTC. Neu: `install-backup.sh`, `restore-test-db.sh` für den monatlichen Restore-Test, `BACKUP_PUSH_URL` in `.env.example`, Runbook `restore.md` (RPO 24 h, RTO 4 h). Vor großen Server-Änderungen ein Hetzner-Snapshot (`deploy.md`). `server-zugang.md`: SSH auch in ufw nur noch über Tailscale.
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
