# 0007 – Aufbau eines Backend-Moduls

- **Status:** Ersetzt durch [0009](0009-backend-konventionen.md)
- **Datum:** 2026-10-08

## Kontext

Notion legt fest: modularer Monolith, ein Modul pro Domäne, Schichten Router → Service → Repository.
Offen war, welche Dateien ein Modul hat. Vorbild ist die Domänen-Struktur aus unserem Projekt
`sdx-eye` (angelehnt an „FastAPI Best Practices“).

## Entscheidung

Jedes Modul unter `backend/src/ballup/modules/<modul>/` hat dieselben Dateien:

| Datei | Inhalt |
|---|---|
| `router.py` | HTTP/WebSocket-Endpunkte unter `/v1/<modul>` – nur Request/Response, keine Logik |
| `admin_router.py` | Nur in `courts`, `reports`, `profiles`, `community`, `chat` – Endpunkte unter `/admin/v1/<modul>` |
| `schemas.py` | Pydantic-Modelle für Requests/Responses (das, was in der OpenAPI-Spec landet) |
| `service.py` | Geschäftslogik, Transaktionen, Jobs anstoßen |
| `repository.py` | Einziger Ort mit Datenbankzugriff |
| `models.py` | Datenbank-Modelle (sobald die Datenbank entschieden ist) |
| `dependencies.py` | FastAPI-`Depends` (z. B. „Court existiert“, „User ist Owner“) |
| `exceptions.py` | Fachliche Fehler des Moduls, abgeleitet von `ballup.shared.errors` |
| `constants.py` | Enums, Limits, Fehlercodes des Moduls |

Unterschiede zu `sdx-eye`: `src/ballup/` als echtes Paket (src-Layout statt `src` als Paketname) und
zusätzlich `repository.py`, damit der Service nie direkt mit der Datenbank spricht.

Querschnitt: `core/` (Config, Security/OIDC, DB, Logging, Telemetry), `shared/` (Fehler, Cursor-Pagination,
Idempotenz, Rate Limits), `api/` (bündelt die Router zu `/v1` und `/admin/v1`), `realtime/`, `workers/`.

## Konsequenzen

- Module importieren sich gegenseitig nur über `service.py`, niemals über `repository.py` oder `models.py`.
- Tests spiegeln die Struktur: `tests/unit/modules/<modul>/`, `tests/integration/modules/<modul>/`.
