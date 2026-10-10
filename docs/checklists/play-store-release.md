# Play Store – Release-Checkliste (Android)

## Einmalig

- [ ] Google-Play-Developer-Konto, Zahlungsprofil, Verifizierung abgeschlossen
- [ ] App angelegt, Package `app.ballup`
- [ ] Play App Signing aktiv; Upload-Key sicher abgelegt (nie im Repo)
- [ ] Datensicherheits-Formular („Data safety“) ausgefüllt, passend zur Datenschutzerklärung
- [ ] Inhaltsbewertung (IARC), Zielgruppe, Werbe-Angabe
- [ ] Digital Asset Links (`/.well-known/assetlinks.json`) für App Links auf `ballup.app`
- [ ] Geschlossener Test mit genügend Testern über die von Google geforderte Dauer (Pflicht für neue Konten)

## Pro Release

- [ ] `versionCode` erhöht, `versionName` gesetzt
- [ ] `targetSdk` erfüllt die aktuelle Play-Anforderung
- [ ] Release-Build (`bundleRelease`) mit R8 getestet – nicht nur Debug
- [ ] Baseline Profile aktuell (Startzeit)
- [ ] Neue Berechtigungen begründet (Standort, Kamera, Benachrichtigungen)
- [ ] Store-Listing: Screenshots (Phone + Tablet), Feature-Grafik, kurze/lange Beschreibung, DE + EN
- [ ] Release Notes geschrieben
- [ ] Gestaffelter Rollout (z. B. 10 % → 50 % → 100 %), Crash-Rate beobachtet
