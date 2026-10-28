# Security-Review: <kurz, Datum>

- **Datum:**
- **Bereich:** API | App | Deploy | Repo
- **Fenster:** von … bis … (Serverzeit)
- **Log-Quelle:** `npm run logs:api` oder `docker compose logs` (kein Roh-Log hierher kopieren)

Regeln: [`../rules.md`](../rules.md). Checklisten nur verlinken, nicht wiederholen.

## Ergebnis

- **Befund:** unauffällig | auffällig
- **Fehler im Fenster:** keine | kurz, ohne Secrets und ohne personenbezogene Daten

## Worauf in den Logs geschaut wird

Nur zählen und bewerten. Keine Angriffswege, keine Payloads.

| Signal | Woran zu erkennen | Bewertung |
|---|---|---|
| Fehlgeschlagene Anmeldungen | Häufung von `401` oder Login-Fehlern auf derselben Quelle | |
| Admin ohne Rolle | `403` auf `/admin/v1` | |
| Rate-Limit | `429` | |
| Unbekannte Pfade | viele `404` auf Pfade, die nicht zur API gehören | |
| Secrets in einer Zeile | Token, Passwort, Key im Logtext | sofort rotieren, Zeile nicht zitieren |

## Maßnahmen

- [ ] …
