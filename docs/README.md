# BallUp-Doku

Zuerst [`status.md`](status.md). Dort steht, was gebaut ist und was nicht.

## Architektur

- [ER-Diagramm](architecture/BallUp_ER-Diagramm.drawio) (draw.io) – Grundlage für alle Datenbank-Änderungen
- [Datenbank-Regeln](guides/database-rules.md)
- [Security-Regeln](security/rules.md) – gelten immer, nicht nur vor dem Release
- [Architecture Decision Records](adr/)

## Checklisten

- [Launch-Readiness](checklists/launch-readiness.md) – Sammelliste vor dem Store-Launch
- [Security (MASVS)](checklists/security-masvs.md)
- [Security](checklists/security.md)
- [Datenschutz/DSGVO](checklists/privacy-dsgvo.md)
- [Barrierefreiheit & Motion](checklists/accessibility-and-motion.md)
- [Backend Go-Live](checklists/backend-go-live.md)
- [Release](checklists/release.md)
- [Play Store Release](checklists/play-store-release.md)
- [App Store Release](checklists/app-store-release.md)
- [Incident](checklists/incident.md)
- [Neues Feature](checklists/new-feature.md)

## Team (KI-Agents)

- [Das KI-Entwicklungsteam](team/agents.md) – Rollen, Abläufe, wie Onur informiert wird
- [Lagebericht](team/lagebericht.md) · [Entscheidungs-Log](team/entscheidungen-log.md) · [Onur-Profil](team/onur-profil.md)
- [Design-System](design/design-system.md) · [Rechtsquellen](legal/quellen.md)

## Business

- [Kosten](costs.md) – einmalig, laufend, pro Nutzer (inkl. KI), Abo-Rechnung, Messung, Geschäftskonto

## Anleitungen

- [Runbook: Backend deployen und zurückrollen](runbooks/deploy.md)
- [Runbook: Datenbank-Backup und Wiederherstellung](runbooks/restore.md)
- [Guide: Mac mini einrichten (iOS-Entwicklung)](guides/mac-mini-setup.md)
- [Guide: Features schneiden und bauen](guides/ai-project-process.md)
- [Changelog](changelog/CHANGELOG.md) – gemergte Änderungen, die den Stand verschieben

## Weitere Ordner

- [specs/](specs/) – eine Spec pro Schnitt (Fachbereich), Vorlage `_template.md`
- [guides/](guides/) – How-tos fürs Team
- [runbooks/](runbooks/) – Betriebsanleitungen
- [postmortems/](postmortems/) – Incident-Auswertungen
- [reviews/](reviews/) – ob ein Test- oder Log-Lauf erfolgreich war
- [security/](security/) – Regeln fürs ganze Projekt, plus Reviews auf Einbruchsversuche in den Logs
- [design/](design/) – Design-System, Motion-Specs, Screens
