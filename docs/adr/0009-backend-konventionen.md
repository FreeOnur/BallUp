# 0009 – Backend-Konventionen nach dem Vorbild von SDX Eye

- **Status:** Akzeptiert
- **Datum:** 2026-10-10
- **Ersetzt:** [0007](0007-backend-modul-aufbau.md)

## Kontext

0007 hat den Modul-Aufbau mit einer zusätzlichen Repository-Schicht festgelegt. In SDX Eye hat sich
eine schlankere Struktur ohne Repository-Layer bewährt, mit klaren Schema- und Namensregeln. BallUp
übernimmt diese Konventionen, damit beide Projekte gleich funktionieren.

## Entscheidung

**Struktur**

- Ein Domain-Ordner pro Fachbereich, **im Singular** (`court/`, `game/`, `user/`), mit den Dateien
  `router.py`, `schemas.py`, `models.py`, `service.py`, `dependencies.py`, `exceptions.py`, `constants.py`.
- **Router → Service**, kein eigener Repository-Layer. Der Service spricht direkt mit der Datenbank-Session.
- `core/` enthält die Basisklassen: `BaseSchema`, `IdMixin`, `TimestampMixin`, `BaseService`.

**Schemas**

- Familie pro Entität: `<Name>Base`, `<Name>In`, `<Name>Update`, `<Name>Out`, `<Name>Model`.
- Geheime oder interne Felder (z. B. Passwort-Hash) stehen **nur** im `Model`, nie in `Out`.
- Jede Route setzt `response_model=`, damit nichts ungefiltert nach außen geht.

**Datenbank**

- Zeitstempel setzt die Datenbank: `DEFAULT now()` für `created_at`, ein Trigger für `updated_at`.

**Namen**

| Was | Regel | Beispiel |
|---|---|---|
| Tabellen | Plural, snake_case | `courts`, `game_results` |
| URLs | Plural, kebab-case | `/v1/courts/{court_id}/check-ins` |
| JSON-Felder | snake_case | `skill_level` |
| Fremdschlüssel | `<entity>_id` | `court_id` |
| Booleans | Präfix `is_` | `is_verified` |
| Zeitpunkte | `<verb>_at` | `created_at`, `deleted_at` |

## Alternativen

| Option | Warum nicht |
|---|---|
| Repository-Layer wie in 0007 | Zusätzliche Indirektion ohne echten Nutzen bei einer einzigen Datenbank; mehr Boilerplate |
| Ordner im Plural | Abweichend von SDX Eye; Singular liest sich im Code besser (`from ballup.court.service import …`) |

## Konsequenzen

- Positiv: Gleiche Konventionen wie SDX Eye, weniger Dateien pro Modul, sichere Antworten durch `response_model`.
- Die Umstellung ist erledigt: Fachordner liegen unter `backend/src/ballup/<bereich>/` im Singular,
  ohne `modules/` und ohne `repository.py`. Der Service spricht mit der Session. Basisklassen stehen
  in `core/` (`BaseSchema`, `IdMixin`, `TimestampMixin`, `SoftDeleteMixin`, `BaseService`),
  HTTP-Fehler in `ballup.exceptions`.
