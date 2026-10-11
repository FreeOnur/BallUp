# App Store – Release-Checkliste (iOS)

## Einmalig

- [ ] Apple-Developer-Programm, Team-ID lokal in Xcode gesetzt (nicht in `project.yml` committen)
- [ ] App-ID `app.ballup.ios` mit Capabilities: Push, Associated Domains, Sign in with Apple (falls Social Login)
- [ ] App in App Store Connect angelegt
- [ ] Apple-App-Site-Association (`/.well-known/apple-app-site-association`) für Universal Links auf `ballup.eu`
- [ ] App-Datenschutz-Angaben („Nutzungslabels“) passend zur Datenschutzerklärung
- [ ] Privacy Manifest (`PrivacyInfo.xcprivacy`) mit genutzten Required-Reason-APIs
- [ ] Altersfreigabe, Kategorie, Preis/Verfügbarkeit
- [ ] Wenn Social Login angeboten wird: Sign in with Apple ebenfalls anbieten (Review-Richtlinie)

## Pro Release

- [ ] `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in `project.yml` erhöht
- [ ] Release-Konfiguration auf echtem Gerät getestet
- [ ] Alle Usage-Description-Texte vorhanden (Standort, Kamera, Fotos, Benachrichtigungen)
- [ ] Account-Löschung in der App möglich (Pflicht, wenn man Accounts anlegen kann)
- [ ] Screenshots für die geforderten Gerätegrößen, DE + EN
- [ ] TestFlight-Build intern + extern getestet
- [ ] Review-Notizen + Demo-Account für Apple-Review hinterlegt
- [ ] Phased Release aktiviert
