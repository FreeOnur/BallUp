# Das KI-Entwicklungsteam

BallUp wird von Onur und einem Team aus Claude-Code-Agents gebaut. Die Rollen liegen in `.claude/agents/`, die Abläufe als Skills in `.claude/skills/`. Entscheidung dazu: [ADR 0020](../adr/0020-ki-entwicklungsteam.md).

## Rollen

| Rolle | Modell | Macht | Darf nicht |
|---|---|---|---|
| **orchestrator** | Opus | Aufträge annehmen, Pipeline bauen, verteilen, Parallelität regeln | selbst Fach-Code schreiben |
| **planner** | Opus | Issues als User Stories, Reihenfolge, Specs (Aufgaben < 400 Zeilen) | bauen, Produktentscheidungen erfinden |
| **builder** | Sonnet | testgetrieben umsetzen, eigener Worktree, PR | auf `main` pushen, Tests aufweichen |
| **tester** | Sonnet | pytest, Android/iOS-Tests, Geräte und Größen, Barrierefreiheit | Fach-Code ändern |
| **reviewer** | Opus | Code-Review mit Zeilenkommentaren | mergen |
| **security** | Opus | Audit pro PR + monatlich, Angriffstests | gegen Produktion oder Fremdsysteme testen |
| **legal** | Opus | Impressum, Datenschutz, AGB, Store, Abo-Recht mit Quellen | Rechtliches zusagen, veröffentlichen |
| **dokumentierer** | Haiku | status.md, CHANGELOG, Specs, Runbooks | Entscheidungen erfinden |
| **entscheider** | Opus | in Onurs Namen wählen, priorisieren, Grünes mergen | Geld, Recht, Veröffentlichen, Löschen, Secrets, Security lockern |
| **ops** | Sonnet | CI, `deploy/`, Backups, Runbooks | Produktion deployen, Server ändern |
| **designer** | Opus | Onurs Design-Regeln lernen und anwenden | Design selbst festlegen |
| **finanzen** | Sonnet | Kosten, Kennzahlen, Warnungen, Steuer-Vorbereitung „Ballup“ | Geld ausgeben |
| **updater** | Sonnet | Lagebericht, Fragen an Onur | etwas schönreden |

## Abläufe (Skills)

| Skill | Wofür |
|---|---|
| `feature-bauen` | eine Story von der Spec bis zum Merge |
| `swarm` | mehrere unabhängige Stories parallel (bis 3, eigene Worktrees) |
| `naechster-schritt` | was ist dran, Onurs Antworten abholen, weitermachen |
| `sicherheits-audit` | Monats-Audit |
| `rechts-check` | Recht und Datenschutz für ein Feature oder vor Release |
| `doku-sync` | Doku auf den Stand des Codes |

## Wie ein Feature durchläuft

```
Onur / Issue
   │
   ▼
orchestrator ──► planner (Issue, Spec, Aufgaben < 400 Zeilen)
   │
   ▼
builder (Worktree, Test zuerst, PR)
   │
   ├──► tester ──┐
   ├──► reviewer ├─► Funde? ──► builder behebt (max. 2 Runden)
   └──► security ┘
   │
   ▼
dokumentierer ──► entscheider (merge oder Frage an Onur) ──► updater (Lagebericht)
```

## Für Onur: zuschauen oder nur Ergebnisse

- **Nur Ergebnisse:** Issue „📋 Lagebericht“ abonnieren (GitHub schickt eine Benachrichtigung pro Bericht) oder `docs/team/lagebericht.md` lesen.
- **Fragen beantworten:** Issues mit Label `question-for-onur`. Antwort einfach als Kommentar („A“ oder eigener Text). Der orchestrator holt sie beim nächsten `naechster-schritt` ab.
- **Zuschauen:** In Claude Code siehst du jeden Agent-Aufruf in der Sitzung und kannst ihn aufklappen (Schritte, gelesene und geänderte Dateien). Läuft ein Agent im Hintergrund, siehst du den Fortschritt und am Ende das Ergebnis.

## Grenzen der Technik

- Subagents können keine Subagents starten. Darum läuft der orchestrator immer in der Hauptsitzung (die Skills machen die Hauptsitzung zum orchestrator).
- Jeder Agent startet ohne Gedächtnis. Was er wissen muss, steht in seiner Pflicht-Lektüre und im Task-Auftrag.
- Agents ersetzen keine echte Rechts- oder Steuerberatung und keinen echten Pentest.
