# Incident-Checkliste

Wenn etwas ausfällt oder Daten in Gefahr sind. Ruhe bewahren, Schritt für Schritt.

## 1. Erkennen (sofort)
- [ ] Wer hat den Alarm bekommen? Diese Person übernimmt bis zur Übergabe
- [ ] Zweiten Gründer informieren
- [ ] Schweregrad festlegen:
  - **S1:** App komplett down oder Datenleck
  - **S2:** Kernfunktion kaputt (Login, Karte, Games)
  - **S3:** Einzelne Funktion oder wenige Nutzer betroffen

## 2. Eindämmen
- [ ] Letztes Deployment schuld? → zurückrollen auf vorheriges Image
- [ ] Neues Feature schuld? → Feature Flag aus
- [ ] App-Update schuld? → Staged Rollout stoppen
- [ ] Verdacht auf Angriff oder Datenleck? → betroffene Tokens/Sitzungen ungültig machen, Secrets rotieren, Zugänge sperren

## 3. Kommunizieren
- [ ] Bei S1/S2: Hinweis in der App bzw. auf Social Media („Wir arbeiten dran“)
- [ ] **Datenleck mit personenbezogenen Daten:** Meldung an die Datenschutzbehörde innerhalb von 72 h, betroffene Nutzer informieren

## 4. Beheben
- [ ] Ursache finden (Logs per `docker compose logs`, Fehler im eigenen Error-Tracking, Traces in Tempo, Metriken in Grafana)
- [ ] Fix über normalen Pull Request, auf Staging testen
- [ ] Bei Datenverlust: Wiederherstellung per PITR auf den Zeitpunkt vor dem Fehler

## 5. Nachbereiten (innerhalb einer Woche)
- [ ] Kurzer Bericht in `docs/incidents/JJJJ-MM-TT-titel.md`: Was ist passiert, Auswirkung, Ursache, Lösung
- [ ] Maßnahmen, damit es nicht wieder passiert (Test, Alarm, Checkliste ergänzen)
- [ ] Kein Schuldiger, sondern bessere Abläufe
