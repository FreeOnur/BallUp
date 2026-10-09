# Release-Checkliste

Für jedes App-Update und jedes Backend-Deployment.

## Vor dem Release
- [ ] Alle Pull Requests reviewt und gemerged, CI grün (Backend, Android, iOS)
- [ ] Versionsnummer erhöht (App) bzw. Image-Tag gesetzt (Backend)
- [ ] Changelog geschrieben (DE/EN für den Store)
- [ ] Datenbank-Migrationen auf Staging getestet, rückwärtskompatibel mit der aktuellen App-Version
- [ ] Neue Features hinter Feature Flag, falls riskant
- [ ] Auf Staging getestet: Login, Karte, Game beitreten, Upload, Push
- [ ] Beide Sprachen geprüft
- [ ] Neue Berechtigungen oder Datenverarbeitung? → Datenschutz-Angaben aktualisiert

## Release
- [ ] Backup direkt vor dem Deployment
- [ ] Backend: Deployment über GitHub Actions (Environment `production`, Freigabe nötig)
- [ ] App: Staged Rollout 5 % → 20 % → 100 %

## Nach dem Release (erste 24 h)
- [ ] Crash-Rate < 1 %, keine neuen ANRs
- [ ] API-Fehlerrate < 2 %, p95 < 300 ms
- [ ] Bei Problemen: Rollout stoppen bzw. Feature Flag aus, siehe `incident.md`
- [ ] Rollout auf 100 % erst nach 48 h ohne Auffälligkeiten
