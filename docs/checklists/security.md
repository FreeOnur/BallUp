# Security-Checkliste

## API

- [ ] Jeder Endpunkt prüft das OIDC-Token (Issuer, Audience, Ablauf, Signatur via JWKS)
- [ ] Autorisierung pro Ressource (nicht nur „eingeloggt“): Owner-/Rollenprüfung in `dependencies.py`
- [ ] `/admin/v1/...` nur mit Admin-Rolle, Admin-Aktionen werden geloggt (Audit)
- [ ] Rate Limits für Login-nahe, Upload- und Chat-Endpunkte
- [ ] Idempotency-Keys für schreibende Endpunkte, die doppelt gesendet werden können
- [ ] Eingaben über Pydantic validiert, Größenlimits für Uploads, Bilder serverseitig geprüft
- [ ] Keine Stacktraces oder internen Fehler in Responses
- [ ] CORS nur so offen wie nötig (Apps brauchen kein CORS)

## Apps

- [ ] Tokens nur im Keystore (Android) / Keychain (iOS), nie in Logs
- [ ] Nur HTTPS, kein Cleartext-Traffic
- [ ] Release-Builds ohne Debug-Logging, R8 aktiv
- [ ] Deep Links validieren ihre Parameter

## Repo & Betrieb

- [ ] Keine Secrets im Repo (GitHub Secret Scanning + Push Protection aktiv)
- [ ] Dependabot-PRs werden regelmäßig gemerged
- [ ] Container laufen als non-root, nur benötigte Ports veröffentlicht
- [ ] Secrets nach Personalwechsel/Leak rotiert
