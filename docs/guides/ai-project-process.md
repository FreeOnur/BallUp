# Features schneiden und bauen

Phasen nur nutzen, wo sie etwas klären. Nicht jede Phase bekommt eine eigene Datei.

Ein Schnitt ist ein durchgängiges Stück Funktion: Backend, Shared, Android und iOS zusammen, alleine lieferbar. Der Name ist der Fachbereich aus der [README](../../README.md) (`court`, `game`, `chat`, …).

## Wo welche Phase liegt

| Phase | Was sie klärt | Bei BallUp |
|---|---|---|
| 0 Konzept | Was wir bauen und für wen | [README](../../README.md) und Notion (Technical Planning) |
| 2 Spezifikation | Anforderungen, Stack, Architektur | [ADRs](../adr/) für Repo, Build und Code. Produkt und Stack in Notion |
| 3 Schnitte planen | Unabhängig baubare Stücke | Die Fachbereiche in der README. Kein eigener Planungsordner |
| 4 Schnitt entwerfen | Abhängigkeiten, Schnittstellen, Erfolg | Eine Spec in [`docs/specs/`](../specs/) aus [`_template.md`](../specs/_template.md) |
| 5 Aufgaben | Kleine Schritte, die eine Agentin umsetzen kann | Abschnitt „Aufgaben“ in derselben Spec |
| 6 Aufgaben schärfen | Dateipfade, Tests, Randfälle nachziehen | Kein eigener Schritt. Fehlt etwas, kommt es in die Spec, bevor der Code beginnt |
| 7 Umsetzen | Code, Tests, abhaken | [Checkliste Neues Feature](../checklists/new-feature.md), Branches und PRs nach [CONTRIBUTING.md](../../CONTRIBUTING.md) |

## Ablauf für einen neuen Schnitt

1. Spec anlegen: `docs/specs/<bereich>.md` aus der Vorlage. Notion-Link und Status oben.
2. Aufgaben so klein schneiden, dass eine Aufgabe ein PR bleibt (ideal unter 400 Zeilen). Jede Aufgabe nennt die Dateien und den Test.
3. Umsetzen nach der Feature-Checkliste. Neue Repo-Entscheidung als ADR, nicht noch einmal in der Spec.
4. Aufgabe in der Spec abhaken, wenn der PR gemergt ist. Eine Zeile in [`docs/changelog/CHANGELOG.md`](../changelog/CHANGELOG.md). Wenn sich der Stand verschiebt, [`docs/status.md`](../status.md) anpassen.
5. Lief dabei ein Test oder ein Log-Fenster: kurze Auswertung nach [`docs/reviews/_template.md`](../reviews/_template.md). Security-Signale (fehlgeschlagene Logins, `403` auf Admin, Rate-Limits) nach [`docs/security/reviews/_template.md`](../security/reviews/_template.md). Die [Security-Regeln](../security/rules.md) gelten bei jedem Schnitt.

Eine zweite Datei `docs/specs/<bereich>.tasks.md` nur, wenn die Aufgabenliste die Spec unlesbar macht. Dieselbe Vorlage, nur der Abschnitt „Aufgaben“.
