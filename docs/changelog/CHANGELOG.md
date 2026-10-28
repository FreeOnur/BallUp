# Changelog

Was sich am Produkt und am Gerüst geändert hat, neueste Zeile oben. Ein Eintrag pro gemergtem PR, der den Stand verschiebt.

Dependabot-Bumps und reine Formatierung stehen hier nicht. Die stehen in `git log`. Keine Secrets, keine Roh-Logs, keine Tokens.

## 2026-10-24

- Founder-Recherche aus dem Repo genommen. Die Dateien liegen im Google Drive, `founder/` steht in `.gitignore`.
- App-ID von `app.ballup` auf `eu.ballup` (Android, iOS, Kotlin-Pakete). ADR 0019.
- Release-Checkliste auf Deploy per npm-Skript. Launch-Preis 4,99 €/Monat.
- Postgres 18 + PostGIS und Alembic. Erste Migration ohne Fach-Tabellen. `/docs` in Produktion aus.
- Backend-Module nach ADR 0009 in Singular-Ordner gelegt, `repository.py` entfernt, `core/` als Basis.
