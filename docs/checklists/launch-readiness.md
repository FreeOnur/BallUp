# Launch-Readiness – „Sind wir bereit für den Store-Launch?“

Erst launchen, wenn **alle** Unterlisten abgehakt sind:
[Backend Go-Live](backend-go-live.md) · [Security](security.md) · [Datenschutz/DSGVO](privacy-dsgvo.md) ·
[Barrierefreiheit & Motion](accessibility-and-motion.md) · [Play Store](play-store-release.md) · [App Store](app-store-release.md)

## Produkt

- [ ] Kern-Flows Ende-zu-Ende getestet: Registrierung/Login, Court finden, Game erstellen/beitreten, Ergebnis melden, Chat
- [ ] Leere Zustände, Ladezustände und Fehlerzustände für jeden Screen gestaltet
- [ ] Offline: App startet ohne Netz, zeigt lokale Daten, synchronisiert danach korrekt
- [ ] Deep Links `ballup.app/...` öffnen den richtigen Screen (Android App Links + iOS Universal Links)
- [ ] Push-Benachrichtigungen kommen auf beiden Plattformen an, Opt-in-Dialog im richtigen Moment
- [ ] Onboarding fertig, Texte Korrektur gelesen (DE + EN)
- [ ] Feature Flags: unfertige Features serverseitig deaktivierbar

## Qualität

- [ ] Testabdeckung Logik + Daten ≥ 70 % (Notion-Vorgabe)
- [ ] Keine bekannten Crashes; eigenes Crash-Reporting liefert Daten in Grafana
- [ ] Kaltstart < 2 s auf einem Mittelklasse-Gerät, Scrollen ohne Ruckler (60/120 fps)
- [ ] Animationen auf einem alten Gerät geprüft (z. B. Android 9 / iPhone mit iOS 18)
- [ ] App-Größe geprüft (R8/Shrinking aktiv, keine unnötigen Assets)
- [ ] Getestet auf: kleinem Phone, großem Phone, Tablet, Dark Mode, große Schrift

## Betrieb

- [ ] Monitoring-Dashboards und Alerts (API down, Fehlerrate, Latenz, Disk voll)
- [ ] Backups laufen **und** Wiederherstellung wurde einmal getestet
- [ ] Runbooks: Deploy, Rollback, Backup-Restore, Incident
- [ ] Statusseite (Uptime Kuma) öffentlich erreichbar

## Recht & Business

- [ ] Datenschutzerklärung, Impressum, AGB/Nutzungsbedingungen online und in der App verlinkt
- [ ] Community-Richtlinien + Meldefunktion + Moderations-Workflow (Reports/Admin)
- [ ] Abos/In-App-Käufe getestet (Sandbox), Preise in allen Märkten gesetzt
- [ ] Support-Kontakt (E-Mail) eingerichtet
