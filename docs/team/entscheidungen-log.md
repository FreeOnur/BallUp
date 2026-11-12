# Entscheidungs-Log

Jede Entscheidung, die der **entscheider** in Onurs Namen trifft oder die Onur über ein Frage-Issue beantwortet. Neueste oben. Regeln: `.claude/agents/entscheider.md`.

| Datum | Was | Optionen | Gewählt | Warum | Wer | Link |
|---|---|---|---|---|---|---|
| 12.11.2026 | PR #202 Force-Update mergen? | A mergen · B vorher 400 → durchlassen · C nicht mergen | A, gemergt | Onur hat selbst gemergt, Empfehlung des entscheiders bestätigt | Onur | #204 |
| 12.11.2026 | PR #202 Force-Update mergen? | A mergen · B vorher 400 → durchlassen · C nicht mergen | vorgelegt, Empfehlung A | Alles grün, aber `deploy/` berührt und 567 Zeilen (> 400) → Pflicht zum Vorlegen. Empfehlung A: keine Sicherheitsfläche, Fehlkonfiguration stoppt den Start (zuverlässig), kleine Middleware ohne neue Abhängigkeit (einfach) | entscheider (wartet auf Onur) | #204 |
| 12.11.2026 | Ungültiger `X-App-Version`-Header (reviewer-Frage #202) | A `400` wie Spec · B durchlassen + loggen | A | Variantenwahl ohne Sicherheitsbezug. Noch sendet keine App den Header; Formatfehler fällt beim Entwickeln laut auf statt das Force-Update in Produktion still auszuhebeln (zuverlässig); PR bleibt wie geprüft (einfach). Bedingung: M1-Test `versionMatchesServerFormat` für alle Build-Typen. Onur kann in #204 überstimmen | entscheider | #202 |
| 11.11.2026 | KI-Entwicklungsteam einrichten | – | 13 Rollen, Skills, Prozess | Auftrag von Onur | Onur | #197 |
