# Security

Regeln, die immer gelten, stehen in [`rules.md`](rules.md). Die gelten für Backend, Apps und Deploy, nicht nur vor einem Release.

Vor Launch und größerem Release bleiben die bestehenden Checklisten die Abhak-Liste. Sie werden hier nicht noch einmal abgeschrieben:

- [Security](../checklists/security.md)
- [Security nach MASVS](../checklists/security-masvs.md)
- [Datenschutz/DSGVO](../checklists/privacy-dsgvo.md)

Ein Review, der Logs auf Einbruchsversuche und Fehler prüft, kommt nach [`reviews/_template.md`](reviews/_template.md). Allgemeine Testläufe (grün oder Fehler, ohne Security-Fokus) nach [`../reviews/_template.md`](../reviews/_template.md).

Logs selbst bleiben auf dem Server (JSON, stdout, Docker-Rotation, ADR 0016). Ins Repo kommt nur die kurze Auswertung, nie ein Roh-Log mit Token, Passwort oder personenbezogenen Daten.
