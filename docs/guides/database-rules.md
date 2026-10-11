# Guide: Datenbank-Regeln

> Regeln für alles, was wir an der Datenbank bauen: Tabellen, Spalten, Indizes, Queries, Migrationen,
> Datenschutz und Skalierung. Jede Regel hat eine Nummer (z. B. **DB-12**), damit man sie im PR-Review
> zitieren kann. Grundlage ist das ER-Diagramm in `docs/architecture/BallUp_ER-Diagramm.drawio`.

**Stand:** 2026-10-10 · PostgreSQL 18 + PostGIS als Hauptdatenbank, Redis für flüchtige Daten und Jobs
([ADR 0008](../adr/0008-postgresql-postgis-und-redis.md)), Backend-Konventionen nach
[ADR 0009](../adr/0009-backend-konventionen.md). Ändert sich eine dieser Entscheidungen, diese Datei anpassen.

## Voraussetzungen

- Das ER-Diagramm ist aktuell. **Erst das Diagramm ändern, dann die Migration schreiben.**
- Datenbankzugriff passiert nur im `service.py` des Moduls, dem die Tabelle gehört (ADR 0009, kein Repository-Layer).

---

## 1. Wo welche Daten hingehören

| Regel | |
|---|---|
| **DB-01** | **PostgreSQL ist die einzige Quelle der Wahrheit.** Alles, was nicht verloren gehen darf, steht dort. |
| **DB-02** | **Redis nur für Flüchtiges oder Ableitbares**: Live-Spielerzahl am Court, Online-Status, Cache, Rate Limits, Job-Queues, WebSocket-Pub/Sub. Wenn Redis komplett leer ist, darf nichts verloren sein. |
| **DB-03** | **Keine Dateien in der Datenbank.** Bilder und Videos liegen im Object Storage, in der DB steht nur die URL bzw. der Objekt-Key. |
| **DB-04** | **Jede Tabelle gehört genau einem Modul** (siehe Tabelle unten). Nur dieses Modul liest und schreibt sie. Andere Module fragen über dessen `service.py`. Fremdschlüssel über Modulgrenzen sind erlaubt. |

### Tabellen pro Modul

| Modul | Tabellen |
|---|---|
| `auth` | users, refresh_tokens |
| `profiles` | profiles |
| `notifications` | notifications, push_tokens |
| `telemetry` | crash_reports |
| `subscriptions` | subscriptions |
| `training` | training_plans, training_sessions |
| `social` | friendships, blocks |
| `chat` | conversations, conversation_members, messages |
| `courts` | courts, court_photos, court_approvals, court_active_users, court_reviews, court_issues |
| `games` | games, game_invites, game_participants, game_results, result_confirmations |
| `rankings` | rating_changes |
| `teams` | teams, team_members |
| `tournaments` | tournaments, tournament_registrations, tournament_matches, match_advancements |
| `clans` | clans, clan_members, clan_media |
| `reports` | reports |

---

## 2. Benennung

| Regel | |
|---|---|
| **DB-05** | Alles auf **Englisch** und in **snake_case**. Tabellen im **Plural** (`courts`), Spalten im Singular (`court_id`). |
| **DB-06** | Fremdschlüssel heißen `<entity>_id` (`court_id`). Wenn eine Tabelle zweimal auf dieselbe zeigt, sagt der Name die Rolle: `requester_id` / `addressee_id`, `team_a_id` / `team_b_id`. |
| **DB-07** | Booleans beginnen mit `is_` / `has_` (`is_ranked`, `has_lights`). Zeitpunkte enden auf `_at` (`expires_at`), reine Daten auf `_date`. |
| **DB-08** | Junction Tables heißen nach ihrer Bedeutung, wenn es eine gibt (`game_participants`, `team_members`), sonst `<a>_<b>`. |
| **DB-09** | Constraint- und Index-Namen fest nach Schema: `pk_<tabelle>`, `fk_<tabelle>_<spalte>`, `uq_<tabelle>_<spalten>`, `ck_<tabelle>_<regel>`, `ix_<tabelle>_<spalten>`. Nie automatisch generierte Namen, sonst sind Migrationen nicht reproduzierbar. |

---

## 3. Primärschlüssel und IDs

| Regel | |
|---|---|
| **DB-10** | Primärschlüssel sind **UUIDv7** (`uuid DEFAULT uuidv7()`, ab PostgreSQL 18 eingebaut). UUIDv7 ist zeitlich sortiert und landet deshalb im Index immer „hinten“ statt zufällig verstreut wie UUIDv4. Außerdem lassen sie sich später ohne Umbau auf mehrere Datenbanken verteilen. |
| **DB-11** | **Keine fortlaufenden Zahlen-IDs nach außen.** Man könnte sonst `/v1/users/1`, `/2`, `/3` durchprobieren und sieht, wie viele User es gibt. |
| **DB-12** | Junction Tables bekommen einen **zusammengesetzten Primärschlüssel** aus den beiden Fremdschlüsseln (`PRIMARY KEY (game_id, user_id)`), keine extra `id`. Das verhindert Doppel-Einträge automatisch. |

---

## 4. Datentypen

| Regel | |
|---|---|
| **DB-13** | Zeit immer als **`timestamptz`**, gespeichert in UTC. Nie `timestamp` ohne Zeitzone. Umrechnen in Ortszeit macht die App. |
| **DB-14** | Text als **`text`**, Längen-Limits per `CHECK (char_length(name) <= 50)`. Das Limit steht zusätzlich in `schemas.py`, die DB ist die letzte Absicherung. |
| **DB-15** | **Geld als ganze Cent in `bigint`** (`price_cents`), nie `float`. |
| **DB-16** | Orte als **`geography(Point, 4326)`** (PostGIS), nicht als zwei `float`-Spalten. Nur so funktionieren „Courts im Umkreis von 5 km“-Abfragen schnell. |
| **DB-17** | Enums als **`text` + `CHECK (status IN ('open', 'full', …))`**, nicht als PostgreSQL-`ENUM`-Typ. Aus einem `ENUM`-Typ kann man keine Werte mehr entfernen. Den gleichen Enum gibt es in `constants.py`. |
| **DB-18** | **`jsonb` nur für wirklich freie Struktur**, die wir nicht filtern oder joinen: KI-Trainingsplan, Shot-Chart, Notification-Payload. Alles, wonach gesucht, sortiert oder verknüpft wird, ist eine echte Spalte. |
| **DB-19** | Keine Listen von IDs in einer Spalte (`uuid[]`, kommagetrennter Text). Dafür gibt es Junction Tables. |

---

## 5. Pflichtspalten und Löschen

| Regel | |
|---|---|
| **DB-20** | **Jede Tabelle hat `created_at` und `updated_at`** (`timestamptz NOT NULL DEFAULT now()`). `updated_at` setzt ein gemeinsamer Trigger bei jedem `UPDATE`. Das darf nicht im Code vergessen werden können. |
| **DB-21** | **Soft Delete (`deleted_at`) nur, wo man es wirklich braucht**: courts, games, teams, clans, messages, court_photos. Überall sonst wird echt gelöscht. |
| **DB-22** | Bei Soft Delete gelten Unique-Regeln nur für nicht gelöschte Zeilen: `CREATE UNIQUE INDEX … ON clans (name) WHERE deleted_at IS NULL`. Sonst kann niemand den Namen eines gelöschten Clans wieder nehmen. |
| **DB-23** | Jede Abfrage auf Soft-Delete-Tabellen filtert `deleted_at IS NULL`. Das passiert zentral im `BaseService`, nicht in jeder Query neu. |

---

## 6. Constraints – Regeln gehören in die Datenbank

> Was die Datenbank erzwingt, kann kein Bug, kein Script und kein zweiter Server-Prozess kaputt machen.

| Regel | |
|---|---|
| **DB-24** | **`NOT NULL` ist Standard.** Eine Spalte darf nur leer sein, wenn „leer“ eine echte Bedeutung hat (z. B. `winner_team_id` = noch kein Gewinner). |
| **DB-25** | **Jeder Fremdschlüssel ist ein echter `FOREIGN KEY`** mit bewusst gewähltem `ON DELETE`: `RESTRICT` als Standard, `CASCADE` nur für Daten, die ohne den Elternteil keinen Sinn haben (z. B. `game_participants` beim Löschen eines Games). |
| **DB-26** | **Geschäftsregeln als Constraint**, wo es geht. Beispiele aus dem ER-Diagramm: `court_active_users.user_id` als Primärschlüssel (nur ein Court gleichzeitig), `clan_members.user_id` als Primärschlüssel (max. ein Clan), `game_results.game_id UNIQUE` (ein Ergebnis pro Game), `court_reviews (court_id, user_id)` als Primärschlüssel (eine Bewertung pro Court). |
| **DB-27** | **`CHECK` für Wertebereiche**: `rating BETWEEN 1 AND 5`, `score_team_a >= 0`, `team_a_id <> team_b_id`, `blocker_id <> blocked_id`, `requester_id <> addressee_id`, `expires_at > created_at`. |

---

## 7. Indizes

| Regel | |
|---|---|
| **DB-28** | **Jeder Fremdschlüssel bekommt einen Index.** PostgreSQL legt den *nicht* automatisch an. Ohne ihn ist jeder Join langsam, und jedes Löschen im Elternteil durchsucht die ganze Kindtabelle. |
| **DB-29** | **Index nach der Abfrage bauen, nicht nach der Tabelle.** Bei mehreren Spalten zuerst die mit `=`, dann die zum Sortieren oder für Bereiche: Für „Games an Court X ab jetzt, nach Zeit sortiert“ ist das `(court_id, start_time)`. |
| **DB-30** | Geo-Spalten bekommen einen **GiST-Index** (`CREATE INDEX ix_courts_location ON courts USING gist (location)`). |
| **DB-31** | **Partielle Indizes** für häufige Filter: `… WHERE status = 'approved' AND deleted_at IS NULL` auf courts. Kleiner und schneller als ein Index über alles. |
| **DB-32** | **Nicht auf Vorrat indizieren.** Jeder Index macht jedes `INSERT`/`UPDATE` langsamer. Neuer Index nur mit konkreter Abfrage dahinter; ungenutzte Indizes (laut `pg_stat_user_indexes`) werden entfernt. |
| **DB-33** | Neue Abfrage auf eine große Tabelle → **`EXPLAIN ANALYZE` mit realistischen Daten** prüfen. Ein `Seq Scan` auf einer großen Tabelle im Hot Path ist ein Bug. |
| **DB-34** | In Produktion Indizes immer mit **`CREATE INDEX CONCURRENTLY`** anlegen, sonst ist die Tabelle während des Aufbaus für Schreibzugriffe gesperrt. |

---

## 8. Queries

| Regel | |
|---|---|
| **DB-35** | Datenbankzugriff steht **nur in `service.py`**. Router kennen keine Tabellen und rufen nur den Service auf. |
| **DB-36** | **Nur parametrisierte Queries**, nie Strings mit User-Eingaben zusammenbauen (SQL-Injection). |
| **DB-37** | **Kein `SELECT *`.** Nur die Spalten holen, die gebraucht werden. |
| **DB-38** | **Listen immer mit Cursor-Pagination** (`WHERE (created_at, id) < (:cursor_ts, :cursor_id) ORDER BY created_at DESC, id DESC LIMIT 50`), nie mit `OFFSET`. `OFFSET 10000` liest 10.000 Zeilen, nur um sie wegzuwerfen. Helfer liegt in `shared/`. |
| **DB-39** | **Jede Liste hat ein `LIMIT`** (Standard 50, Maximum 100). |
| **DB-40** | **Keine N+1-Queries**: nicht in einer Schleife pro Element nachladen, sondern alles in einer Abfrage (`WHERE id = ANY(:ids)`) oder per Join. |
| **DB-41** | **Joins im Hot Path klein halten** (Richtwert: höchstens 3–4 Tabellen). Bei OpenAI war eine Abfrage über 12 Tabellen an schweren Ausfällen beteiligt. Lieber zwei einfache Queries im Code zusammensetzen. |
| **DB-42** | **Kein `COUNT(*)` über große Tabellen bei jedem Request.** Häufig gebrauchte Zahlen werden mitgeführt: als Spalte (`approval_count`) oder in Redis (Live-Spielerzahl). |
| **DB-43** | Jede Verbindung hat einen **`statement_timeout`** (z. B. 5 s für API-Requests). Eine hängende Abfrage darf nicht den ganzen Server blockieren. |

---

## 9. Transaktionen und gleichzeitige Zugriffe

| Regel | |
|---|---|
| **DB-44** | **Transaktionen startet der Service**, nie der Router. Alles, was zusammen gelingen muss, steht in einer Transaktion: z. B. Ergebnis bestätigen + ELO für alle Spieler + `rating_changes` schreiben. |
| **DB-45** | **Transaktionen kurz halten.** Darin keine HTTP-Aufrufe, keine Push-Nachrichten, keine Uploads. Solche Dinge laufen nach dem Commit als Job (Redis-Worker). |
| **DB-46** | **Konkurrierende Updates absichern.** Wenn zwei Requests gleichzeitig dieselbe Zeile ändern können (z. B. zwei Spieler joinen gleichzeitig das letzte Spot im Game), die Zeile mit `SELECT … FOR UPDATE` sperren oder atomar zählen (`UPDATE … SET x = x + 1 WHERE x < max`). |
| **DB-47** | Schreibende Endpunkte, die die App bei schlechtem Netz wiederholt (Game erstellen, Ergebnis melden), sind **idempotent**: Die App schickt einen Idempotency-Key mit, der Server führt denselben Key nur einmal aus. Helfer liegt in `shared/`. |
| **DB-48** | `idle_in_transaction_session_timeout` ist gesetzt (z. B. 30 s). Offen vergessene Transaktionen blockieren sonst das Aufräumen der DB (Autovacuum). |

---

## 10. Migrationen

| Regel | |
|---|---|
| **DB-49** | **Jede Schema-Änderung ist eine Migration** in `backend/migrations/`, im selben PR wie der Code. Nie per Hand an der Produktions-DB ändern. |
| **DB-50** | **Eine Migration, die schon auf einem Server lief, wird nie mehr geändert.** Fehler werden mit einer neuen Migration korrigiert. |
| **DB-51** | **Ändern ohne Ausfall in Schritten (Expand → Migrate → Contract):** 1) neue Spalte nullable anlegen, 2) Code schreibt alt + neu, 3) alte Daten in kleinen Paketen nachfüllen, 4) Code liest nur noch neu, 5) im nächsten Release die alte Spalte löschen. Nie Spalte umbenennen oder löschen im selben Release, in dem der Code sie noch nutzt. |
| **DB-52** | Migrationen setzen **`lock_timeout`** (z. B. 5 s). Bekommt sie die Sperre nicht schnell, bricht sie ab, statt alle Requests hinter sich warten zu lassen. |
| **DB-53** | Große Datenmengen (Backfills) **in Paketen** von z. B. 1.000–10.000 Zeilen mit Pause, nie in einem Rutsch. |
| **DB-54** | Die CI spielt alle Migrationen auf einer leeren DB ein und führt die Integrationstests dagegen aus. |

---

## 11. Datenschutz und Sicherheit

| Regel | |
|---|---|
| **DB-55** | **Nur speichern, was ein Feature wirklich braucht** (DSGVO, Datenminimierung). Neue personenbezogene Spalte → kurz in `docs/checklists/privacy-dsgvo.md` prüfen. |
| **DB-56** | **Passwörter, Refresh-Tokens und Einladungs-Codes nur gehasht** speichern (Passwörter mit Argon2id), falls wir sie überhaupt selbst speichern. |
| **DB-57** | **Standortdaten so kurz wie möglich halten.** `court_active_users` speichert nur den aktuellen Check-in, keine Bewegungshistorie. Wenn Statistiken nötig sind, dann nur zusammengezählt pro Court und Tag. |
| **DB-58** | **Account löschen** löscht oder anonymisiert alle personenbezogenen Daten. Was aus Integritätsgründen bleiben muss (Spielergebnisse, ELO-Historie der Gegner), zeigt danach auf einen anonymen „Gelöschter Spieler“. |
| **DB-59** | **Getrennte Datenbank-Rollen**: Die API darf lesen und schreiben, aber keine Tabellen ändern. Migrationen laufen mit eigener Rolle. Auswertungen nur mit Lese-Rolle. |
| **DB-60** | **Keine personenbezogenen Daten in Logs** (keine E-Mails, keine Standorte, keine Nachrichteninhalte). Nur IDs. |
| **DB-61** | **Backups**: nächtlicher Dump plus fortlaufende WAL-Archivierung (Wiederherstellen auf jede Minute möglich), verschlüsselt und außerhalb des Servers gespeichert. **Wiederherstellen wird regelmäßig getestet**, siehe `docs/runbooks/`. |

---

## 12. Redis

| Regel | |
|---|---|
| **DB-62** | **Jeder Key hat ein TTL** (Ablaufzeit), außer Queues. |
| **DB-63** | Keys nach Schema `ballup:<modul>:<was>:<id>`, z. B. `ballup:courts:live_count:<court_id>`. |
| **DB-64** | **Cache wird beim Schreiben ungültig gemacht**, nicht nur per TTL. Wer einen Court ändert, löscht `ballup:courts:detail:<id>`. |

---

## 13. Skalierung – was wir heute schon richtig machen und was später kommt

Heute (ein Server) reichen die Regeln oben. Damit wir später nicht umbauen müssen, gilt schon jetzt:

| Regel | |
|---|---|
| **DB-65** | **Lesen und Schreiben im Service trennen** (eigene Methoden bzw. eigene Session für reine Lese-Abfragen). Später zeigen die Lese-Abfragen dann auf Lese-Kopien, ohne dass Router sich ändern. |
| **DB-66** | **Große, wachsende Tabellen von Anfang an mit Zeit-Spalte und UUIDv7** anlegen: `messages`, `notifications`, `rating_changes`, `crash_reports`. Die kann man später nach Monat partitionieren und alte Monate günstig archivieren. |
| **DB-67** | **Chat so bauen, dass er umziehen kann**: `messages` werden nur über `conversation_id` + Zeit abgefragt, ohne Joins auf andere Module. Dann lässt sich die Tabelle bei Bedarf allein nach ScyllaDB/Cassandra verschieben. |
| **DB-68** | **Monitoring ab Tag 1**: `pg_stat_statements` an, langsame Abfragen (> 200 ms) loggen, Dashboards in Grafana für Verbindungen, Cache-Trefferquote, Replikations-Verzögerung und Autovacuum. |

**Ausbaustufen**, jeweils erst wenn das Monitoring es zeigt:

1. PgBouncer vor die Datenbank (bündelt Verbindungen) und mehr in Redis cachen.
2. Eigener, größerer Datenbank-Server. Lese-Endpunkte (Karte, Profile, Ranglisten) über Lese-Kopien.
3. Große Zeit-Tabellen nach Monat partitionieren.
4. Tabellen mit sehr vielen Schreibzugriffen auslagern, vor allem `messages` zu ScyllaDB.
5. Erst bei sehr großer Last: PostgreSQL selbst aufteilen (z. B. mit Citus, Aufteilung nach Region).

---

## Checkliste für jede neue Tabelle (PR)

- [ ] Im ER-Diagramm eingetragen, Modul-Besitzer festgelegt (DB-04)
- [ ] Namen nach DB-05 bis DB-09
- [ ] UUIDv7-Primärschlüssel oder zusammengesetzter Schlüssel (DB-10, DB-12)
- [ ] `created_at`, `updated_at`, ggf. `deleted_at` (DB-20, DB-21)
- [ ] `NOT NULL`, Fremdschlüssel mit `ON DELETE`, `UNIQUE`/`CHECK` für Geschäftsregeln (DB-24 bis DB-27)
- [ ] Index auf jeden Fremdschlüssel und für jede neue Abfrage (DB-28, DB-29)
- [ ] Listen mit Cursor-Pagination und `LIMIT` (DB-38, DB-39)
- [ ] Migration nach Expand/Contract, mit `lock_timeout` (DB-49 bis DB-52)
- [ ] Personenbezogene Daten geprüft (DB-55 bis DB-58)

## Häufige Probleme

- **„Die Abfrage ist plötzlich langsam“** → `EXPLAIN ANALYZE` laufen lassen, meistens fehlt ein Index (DB-28/29) oder es wird `OFFSET` benutzt (DB-38).
- **„Migration hängt in Produktion“** → Sie wartet auf eine Sperre. `lock_timeout` fehlt (DB-52) oder es wurde ein Index ohne `CONCURRENTLY` gebaut (DB-34).
- **„Doppelte Einträge“** → Es fehlt ein `UNIQUE`-Constraint oder ein zusammengesetzter Primärschlüssel (DB-12, DB-26); die Prüfung nur im Code reicht bei gleichzeitigen Requests nicht.
- **„Datenbank wird immer größer, obwohl wir löschen“** → Autovacuum wird durch offene Transaktionen blockiert (DB-48).
