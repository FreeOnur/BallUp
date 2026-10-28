# Stand

Zuerst diese Datei lesen. Sie ersetzt kein ADR und keinen Code. Sie sagt, wo das Projekt gerade steht, damit nicht das ganze Repo neu gelesen werden muss.

Stand: 2026-10-28. Nach jeder Änderung, die den Stand verschiebt, diese Datei anpassen. Einzelne Commits stehen in [`changelog/CHANGELOG.md`](changelog/CHANGELOG.md), die volle Historie in `git log`.

## Produkt

Pickup-Basketball-App. Android (Kotlin, Compose), iOS (Swift, SwiftUI), geteilte Data- und Domain-Schicht (Kotlin Multiplatform). Backend ist ein FastAPI-Monolith. Abo-Preis in den Checklisten: 4,99 €/Monat. Domain `ballup.eu`. App-ID `eu.ballup`.

Notion (Technical Planning) hält Produkt und Stack. Entscheidungen zum Repo stehen in [`adr/`](adr/).

## Was schon steht

- Backend-Gerüst nach ADR 0009: ein Ordner pro Fachbereich direkt unter `backend/src/ballup/`, ohne `repository.py`. `core/` hat Settings, Schemas, Models, Session und `BaseService`. Einziger Endpunkt: `/health`.
- Postgres 18 + PostGIS, Alembic. Migration `0001_postgis`: Extension und `set_updated_at()`. Keine Fach-Tabellen.
- `/docs` ist aus, wenn `BALLUP_ENV=production` ist. Vertrag über `backend/scripts/export_openapi.py`.
- Deploy per `npm run deploy` / `deploy:api` (ADR 0018). Logs: JSON auf stdout, Docker-Rotation, kein Loki (ADR 0016).
- Mobile-Pakete und Bundle-IDs sind `eu.ballup` (ADR 0019).

## Was noch nicht steht

Keine Fach-Endpunkte, keine Login-Logik, keine Fach-Tabellen, kein Store-Upload. Ob die neue Migration auf dem Hetzner-Server schon gelaufen ist, steht nicht in diesem Repo. Der lokale Nachweis war `uv run alembic upgrade head` gegen `compose.dev`.

## Wo als Nächstes nachlesen

| Frage | Datei |
|---|---|
| Wie ein Schnitt gebaut wird | [`guides/ai-project-process.md`](guides/ai-project-process.md) |
| Security, immer | [`security/rules.md`](security/rules.md) |
| Security vor einem Release | [`checklists/security.md`](checklists/security.md), [`checklists/security-masvs.md`](checklists/security-masvs.md) |
| Ob ein Lauf sauber war | [`reviews/_template.md`](reviews/_template.md) |
| Datenbank | [`guides/database-rules.md`](guides/database-rules.md) |
