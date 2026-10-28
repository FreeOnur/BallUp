# Security-Regeln

Gelten für das ganze Repo, ab dem ersten Fach-Code. Die Release-Checklisten prüfen dieselben Punkte vor dem Launch. Hier steht, was im Alltag nicht verhandelbar ist.

## Geheimnisse

- Keine Secrets, Tokens, Passwörter oder Schlüssel in Git, Commits, PR-Texten, Logs, Reviews oder dieser Doku.
- Werte nur in `.env` (nicht committen) oder in den Secrets des Deploy-Ziels. Vorlagen bleiben `.env.example`.
- Nach einem Leak oder Personenwechsel werden die betroffenen Secrets rotiert.

## Zugriff

- Jeder geschützte Endpunkt prüft das Access-JWT serverseitig (Signatur, Ablauf, Audience). Die App allein reicht nicht.
- Autorisierung gilt pro Ressource, in `dependencies.py`. `/admin/v1` nur mit Admin-Rolle.
- Google- und Apple-Tokens werden beim Login serverseitig geprüft, sobald Auth gebaut ist (ADR 0010). Login-Bibliotheken kommen mit diesem Modul, nicht vorher.
- Rate Limits auf Login-nahen, Upload- und Chat-Endpunkten. Schreibende Endpunkte, die doppelt ankommen können, nehmen einen Idempotency-Key.

## Daten und Fehler

- Eingaben über Pydantic. Datenbankzugriffe parametrisiert. Kein SQL aus Zeichenketten zusammensetzen.
- Antworten enthalten keine Stacktraces und keine internen Fehler.
- Uploads haben ein Größenlimit. Bilder werden serverseitig geprüft.
- CORS nur so offen wie nötig. Die Apps brauchen kein offenes CORS.
- Passwörter, sobald es sie gibt: Argon2id, Salt und Pepper. Der Pepper bleibt in der Server-Umgebung.

## Logs

- Strukturiertes JSON auf stdout. Docker rotiert (`max-size` 50m, `max-file` 10). Lesen mit `npm run logs` oder `docker compose logs`. Kein Loki (ADR 0016).
- Nie loggen: Access-Token, Refresh-Token, Passwort, Pepper, API-Keys, komplette Request-Bodies mit Zugangsdaten.
- Diese Ereignisse werden geloggt, sobald der Pfad existiert: fehlgeschlagene Anmeldung, `401`, `403` auf `/admin/v1`, Rate-Limit (`429`), abgelehnter Upload. Admin-Aktionen zusätzlich als Audit.
- Apps: Tokens nur in Keystore oder Keychain. Release-Builds ohne Debug-Logging.

## Betrieb

- Container laufen als non-root. Postgres hat in Produktion keinen veröffentlichten Port.
- Nur HTTPS. Der Datenbank-Port ist nicht öffentlich.
- Dependabot-PRs werden gemergt, bekannte Lücken bleiben nicht liegen.
- Eine neue Security-Entscheidung wird ein ADR. Diese Datei bekommt dann einen Satz und einen Link, keine zweite lange Begründung.
