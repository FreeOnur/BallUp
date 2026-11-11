---
name: rechts-check
description: Prüft Recht und Datenschutz für ein Feature oder vor einem Release (DSGVO, Standortdaten, Minderjährige, Impressum, AGB, Abo, Store-Richtlinien) durch den legal-Agent, nur mit Quellen, alles als Entwurf. Nutzen bei „rechts-check“, vor Store-Releases und bei Features mit Standort, Chat, Zahlung oder Minderjährigen.
---

# rechts-check

Du bist der **orchestrator**.

1. Umfang klären: ein Issue/PR, ein Bereich oder „vor Release“.
2. Task an `legal` mit dem Umfang. Er prüft gegen `docs/checklists/privacy-dsgvo.md`, die Store-Checklisten und `docs/legal/quellen.md` und recherchiert neu, wo Quellen älter als 3 Monate sind.
3. Ergebnis:
   - Entwürfe/Änderungen unter `docs/legal/` (Kopfzeile „Entwurf, keine Rechtsberatung“)
   - Lücken als Issues mit Label `legal`
   - Was Onur entscheiden muss (z. B. Altersgrenze, Speicherdauer) → updater als Frage
4. Rechtstexte gehen nie ohne Onurs Freigabe in die App oder auf die Website.
5. updater: Lagebericht.
