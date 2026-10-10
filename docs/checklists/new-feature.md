# Neues Feature – „Ist es fertig?“

## Vorher

- [ ] Spec in `docs/specs/` (aus `_template.md`) oder Notion-Aufgabe mit Akzeptanzkriterien
- [ ] API-Entwurf abgestimmt; neue Entscheidungen → ADR

## Backend (`backend/src/ballup/modules/<modul>/`)

- [ ] `schemas.py` → `router.py` → `service.py` → `repository.py`, Fehler in `exceptions.py`
- [ ] Router in `api/v1.py` (bzw. `api/admin_v1.py`) registriert
- [ ] Datenbank-Änderungen nach [Datenbank-Regeln](../guides/database-rules.md): ER-Diagramm, Migration, Indizes, Constraints
- [ ] Unit-Tests für Service, Integrationstests für Router
- [ ] `contracts/openapi.json` aktualisiert

## Shared (`mobile/shared/feature/<feature>/`)

- [ ] API-Client neu generiert (`./gradlew :shared:core:network:openApiGenerate`)
- [ ] SQLDelight-Tabellen/Queries + Migration in `shared/core/database`
- [ ] Repository: liest aus lokaler DB, aktualisiert vom Server (offline-first)
- [ ] Use Case nur bei komplexer Logik
- [ ] Koin-Modul registriert, Tests in `commonTest`

## Android (`mobile/androidApp/feature/<feature>/`)

- [ ] ViewModel mit **einem** UI-State, Events in eine Richtung
- [ ] Screens nutzen nur Design-System-Komponenten, Previews für alle Zustände
- [ ] Navigation im App-Modul eingehängt

## iOS (`mobile/iosApp/BallUp/Features/<Feature>/`)

- [ ] `@Observable`-ViewModel mit einem State, ruft Shared-Repositories/Use Cases
- [ ] Views nutzen `Core/DesignSystem`, Previews für alle Zustände

## Abschluss

- [ ] Checkliste [Barrierefreiheit & Animationen](accessibility-and-motion.md) für die neuen Screens
- [ ] Feature Flag gesetzt, falls schrittweiser Rollout
- [ ] PR-Template vollständig ausgefüllt
