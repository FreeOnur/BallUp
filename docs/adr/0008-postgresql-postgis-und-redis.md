# 0008 – PostgreSQL + PostGIS als Datenbank, Redis für Cache, Live-Daten und Jobs

- **Status:** Akzeptiert
- **Datum:** 2026-10-10

## Kontext

BallUp ist stark ortsbezogen (Courts in der Nähe, Games im Umkreis, Live-Belegung) und hat viele
Beziehungen zwischen Nutzern, Teams, Games, Turnieren und Rankings (siehe
[ER-Diagramm](../architecture/BallUp_ER-Diagramm.drawio)). Die Datenbank war bisher offen;
`models.py` in den Modulen wartete auf diese Entscheidung (0007).

## Entscheidung

- **PostgreSQL** mit **PostGIS** ist die einzige primäre Datenbank. Geo-Abfragen (Umkreis, Bounding Box
  der Karte) laufen über PostGIS-Typen und GiST-Indizes.
- **Redis** für Cache, kurzlebige Live-Daten (z. B. wer gerade an einem Court ist, WebSocket-Fan-out)
  und als **Job-Queue** (ARQ oder Celery; die Wahl fällt mit dem ersten Hintergrund-Job).
- **IDs:** UUIDv7 (zeitlich sortierbar, gut für Indizes, nicht erratbar).
- **Soft Delete** über eine Spalte `deleted_at`; Abfragen filtern standardmäßig auf `deleted_at IS NULL`.
  Echte Löschung (z. B. Konto löschen nach DSGVO) ist ein eigener, expliziter Prozess.
- **Migrationen** mit **Alembic**, eine Migration pro PR mit Schemaänderung.
- Regeln im Detail: [Datenbank-Regeln](../guides/database-rules.md).

## Alternativen

| Option | Warum nicht |
|---|---|
| MongoDB | Viele Relationen und Konsistenz-Regeln (Constraints) – das spielt eine relationale DB besser aus; Geo geht in PostGIS mindestens genauso gut |
| Supabase | Bindet uns an einen Anbieter samt eigener Auth/Storage; wir wollen Postgres selbst auf Hetzner betreiben |
| Auto-Increment-IDs | Erratbar, verraten Mengen, schwierig beim Offline-Anlegen in der App |
| UUIDv4 | Zufällige Reihenfolge, schlechtere Index-Lokalität als UUIDv7 |

## Konsequenzen

- Positiv: Ein bewährter Stack, Geo-Abfragen direkt in SQL, Constraints sichern Geschäftsregeln ab.
- Negativ / Aufwand: Postgres-Betrieb (Backups, Upgrades, Restore-Tests) liegt bei uns.
- `compose.yml` bekommt einen `postgres`-Service (PostGIS-Image), sobald das erste Modul persistiert.
