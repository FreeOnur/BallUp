# Launch-Readiness

Alles, was vor dem öffentlichen Launch erledigt sein muss. Erst wenn jeder Punkt abgehakt oder bewusst
mit Begründung verschoben ist, geht die App in die Stores.

Unterlisten: [Backend Go-Live](backend-go-live.md) · [Security (MASVS)](security-masvs.md) · [Security](security.md) ·
[Datenschutz/DSGVO](privacy-dsgvo.md) · [Barrierefreiheit & Motion](accessibility-and-motion.md) ·
[Release](release.md) · [Play Store](play-store-release.md) · [App Store](app-store-release.md) · [Incident](incident.md)

## Produkt
- [ ] Alle Phase-1-Features fertig und auf Android + iOS getestet (Karte, Courts, Auth, Profil, Uploads)
- [ ] Onboarding inkl. Skill-Level-Auswahl und Analytics-Einwilligung
- [ ] Gast-Modus: Karte und Games ohne Konto sichtbar, Beitreten nur mit Konto
- [ ] Leere Zustände mit Ausweg („Trag den ersten ein“)
- [ ] Fehler- und Offline-Zustände auf jedem Screen
- [ ] Deutsch und Englisch vollständig, längste Texte im Layout geprüft
- [ ] Barrierefreiheit Grundlagen: große Schrift, Screenreader-Labels, Kontrast
- [ ] Courts in Vorarlberg vorab eingetragen (keine leere Karte)

## Performance (Ziele aus Non-Functional-Requirements)
- [ ] Cold Start < 2 s, Warm Start < 1 s auf Mittelklasse-Handy
- [ ] Karte zeigt Courts in ≤ 2 s
- [ ] 60 fps beim Scrollen, keine ANRs im Test
- [ ] App-Download < 50 MB
- [ ] API p95 < 300 ms unter Last-Test
- [ ] Akku ≤ 5 % pro Stunde mit offener Karte

## Sicherheit
- [ ] `security-masvs.md` vollständig durchgegangen
- [ ] Keine Secrets im Repo (Secret Scanning grün)
- [ ] Rate Limits aktiv (Login, Registrierung, Uploads, Nachrichten)
- [ ] Admin-Zugänge mit 2FA

## Recht & Datenschutz
- [ ] Datenschutzerklärung und AGB vom Anwalt, in der App und im Store verlinkt
- [ ] AVV mit allen Anbietern (Hetzner, Mapbox, Resend, Mistral, Apple/Google)
- [ ] Mindestalter 14 + Einschränkungen für 14–17 umgesetzt
- [ ] Konto löschen funktioniert vollständig (inkl. Medien)
- [ ] Prozess für Datenauskunft per Mail (Antwort ≤ 30 Tage)
- [ ] Impressum

## Betrieb
- [ ] Backups laufen, Wiederherstellung einmal erfolgreich getestet
- [ ] Monitoring, Alarme (Push, Mail, WhatsApp) und Uptime-Check aktiv
- [ ] Crash-Reporting liefert Daten aus Android und iOS
- [ ] Staging-Server läuft, Release wurde dort zuerst getestet
- [ ] Force-Update-Mechanismus getestet
- [ ] `incident.md` bekannt, Zuständigkeiten klar

## Stores
- [ ] Apple Developer Program + Google Play Konto aktiv
- [ ] Store-Einträge: Name, Beschreibung DE/EN, Screenshots, Altersfreigabe, Datenschutz-Angaben
- [ ] In-App-Abo (8 €) in beiden Stores angelegt und getestet
- [ ] Staged Rollout eingestellt (5 % → 20 % → 100 %)

## Marketing
- [ ] Warteliste / Beta-Gruppe informiert
- [ ] Social-Accounts mit ersten Videos
- [ ] QR-Schilder an den wichtigsten Courts
- [ ] Launch-Event geplant („BallUp Open Vorarlberg“)
