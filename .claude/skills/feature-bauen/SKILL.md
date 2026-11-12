---
name: feature-bauen
description: Baut ein Feature oder eine User Story von der Spec bis zum Merge mit dem ganzen Agent-Team (planner → builder → tester + reviewer + security parallel → builder behebt max. 2 Runden → dokumentierer → entscheider/Merge → updater). Nutzen bei „bau Issue #…“, „setz die Story um“, „feature-bauen #…“.
---

# feature-bauen

Du bist jetzt der **orchestrator** (lies `.claude/agents/orchestrator.md`). Eingabe: eine Issue-Nummer oder eine Beschreibung.

## Ablauf

1. **Vorbereiten:** `docs/status.md` lesen. Issue holen (`gh api repos/FreeOnur/BallUp/issues/<nr>`). Offene Antworten in `frage-an-onur`-Issues abholen. Aufgabenliste mit den Schritten unten anlegen.
   Aufwand einschätzen und Modell wählen (Tabelle „Modellwahl nach Aufwand“ in `orchestrator.md`). Fleißarbeit: Schritt 2 überspringen, builder mit `model: haiku`.
2. **planner** (Task, `subagent_type: planner`): Spec anlegen oder ergänzen, Aufgaben < 400 Zeilen mit Dateien und Tests. Ist etwas blockiert → updater fragt Onur, hier stoppen.
3. **builder** (Task, `subagent_type: builder`) pro Aufgabe: eigener Worktree, testgetrieben, PR. Mehrere unabhängige Aufgaben → Skill `swarm`.
4. **Prüfen parallel** in **einer** Nachricht drei Task-Aufrufe:
   - `tester` mit PR-Nummer
   - `reviewer` mit PR-Nummer
   - `security` mit PR-Nummer
5. **Funde:** blockierende Funde gesammelt an den builder (gleicher Worktree). Danach Schritt 4 nur für die Rollen mit Funden. **Maximal 2 Runden.** Danach: updater meldet das Problem, PR bleibt offen.
6. **dokumentierer:** CHANGELOG, status.md, Spec abhaken (in denselben PR, wenn noch offen, sonst eigener `docs:`-PR).
7. **entscheider:** Merge (Squash) oder Vorlage an Onur nach seinen Regeln. CI-Status prüfen: `gh api repos/FreeOnur/BallUp/commits/<sha>/check-runs`.
8. **updater:** Lagebericht.
9. Worktree aufräumen: `git worktree remove ../ballup-<issue>`.

## Regeln

- Riskante Bereiche (Auth, Migrationen, Zahlung, Standort) laufen einzeln, nie parallel zu anderem am selben Bereich.
- Jeder Agent bekommt im Task-Prompt: Issue-Nummer, PR-Nummer (wenn vorhanden), Spec-Pfad, was genau zu tun ist, was er zurückgeben soll.
- Ergebnisse immer in `docs/` und auf GitHub, nie nur im Chat.
