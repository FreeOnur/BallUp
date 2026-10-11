# Security-Check nach OWASP MASVS

Orientiert an den Bereichen des OWASP Mobile Application Security Verification Standard (MASVS).
Vor jedem größeren Release und spätestens vor dem Launch vollständig durchgehen.
Details zu den Entscheidungen: Notion → Technical Planning → Security.

## Speicherung (MASVS-STORAGE)
- [ ] Tokens nur in Keychain (iOS) / Keystore (Android), nie in SharedPreferences/UserDefaults im Klartext
- [ ] Lokale Datenbank verschlüsselt
- [ ] Keine sensiblen Daten in Logs, Crash-Reports oder Screenshots im App-Switcher
- [ ] Beim Konto-Wechsel auf dem Gerät werden alle lokalen Daten gelöscht

## Kryptografie (MASVS-CRYPTO)
- [ ] Keine eigene Kryptografie, nur geprüfte Bibliotheken
- [ ] Passwörter: Argon2id mit Salt + Pepper (Pepper nur in Server-Umgebung, nicht in der DB)
- [ ] JWT-Signatur mit starkem Schlüssel, Algorithmus fest vorgegeben (kein `none`, kein Algorithmus aus dem Token übernehmen)
- [ ] Schlüssel und Secrets nur über Umgebungsvariablen / GitHub Secrets

## Authentifizierung (MASVS-AUTH)
- [ ] Access-Token 15 min, Refresh-Token mit Rotation und Diebstahl-Erkennung
- [ ] Abmeldung nach 30 Tagen Inaktivität
- [ ] „Auf allen Geräten abmelden“ beendet wirklich alle Sitzungen
- [ ] Google/Apple-ID-Token serverseitig geprüft (Signatur, Aussteller, Audience, Ablauf)
- [ ] Passwort-Reset-Links einmalig und kurz gültig
- [ ] Rate Limit und Sperre nach Fehlversuchen beim Login
- [ ] Benachrichtigung bei Login von neuem Gerät
- [ ] Jede API-Route prüft Berechtigungen serverseitig (nicht nur in der App)
- [ ] Rollen (User/Moderator/Admin) getestet, Admin-Routen nur unter `/admin/v1`

## Netzwerk (MASVS-NETWORK)
- [ ] Nur HTTPS/TLS, kein Klartext-Traffic erlaubt (Android Network Security Config, iOS ATS)
- [ ] Datenbank-Port nicht öffentlich
- [ ] Server nur per SSH-Key, Admin-Zugänge über VPN

## Plattform (MASVS-PLATFORM)
- [ ] Deep Links prüfen alle Parameter, keine Aktion ohne Bestätigung
- [ ] WebViews (falls vorhanden) ohne unnötiges JavaScript und ohne Datei-Zugriff
- [ ] Berechtigungen (Standort, Kamera, Mikrofon) nur wenn nötig und mit Erklärung

## Code (MASVS-CODE)
- [ ] Alle Eingaben serverseitig über Pydantic validiert
- [ ] Datenbankzugriffe nur parametrisiert
- [ ] Abhängigkeiten ohne bekannte Lücken (Dependabot grün)
- [ ] Force-Update für unsichere App-Versionen möglich

## Widerstandsfähigkeit (MASVS-RESILIENCE)
- [ ] Obfuscation aktiv (R8 / Symbol-Stripping)
- [ ] Play Integrity / App Attest für Registrierung, Ergebnisse, Ranking

## Privatsphäre (MASVS-PRIVACY)
- [ ] Analytics erst nach Einwilligung
- [ ] EXIF/GPS aus Fotos entfernt
- [ ] Standort nie als Koordinaten an andere Nutzer
- [ ] Datenschutz-Angaben in den Stores stimmen mit der App überein
