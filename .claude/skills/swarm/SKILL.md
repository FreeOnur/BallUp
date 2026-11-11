---
name: swarm
description: Baut mehrere unabhängige Schnitte oder Aufgaben gleichzeitig, jeden in einem eigenen Git-Worktree (bis 3 parallel). Nutzen bei „bau die nächsten Stories parallel“, „swarm“, oder wenn feature-bauen mehrere unabhängige Aufgaben hat.
---

# swarm

Du bist der **orchestrator** (`.claude/agents/orchestrator.md`).

## 1. Prüfen, was wirklich parallel geht

Für jede Aufgabe die betroffenen Dateien aus der Spec sammeln. Zwei Aufgaben sind **abhängig**, wenn sie
- dieselbe Datei ändern, oder
- dieselbe Tabelle bzw. eine Migration haben, oder
- `contracts/openapi.json` an derselben Stelle ändern, oder
- eine von beiden Auth, Zahlung, Standortdaten oder Migrationen betrifft.

Abhängige Aufgaben laufen nacheinander. Unabhängige höchstens **3** gleichzeitig.

## 2. Worktrees anlegen

```
git fetch origin main
git worktree add ../ballup-<issue> -b <typ>/<issue>-<kurz> origin/main
```

## 3. Bauen

In **einer** Nachricht je Aufgabe einen Task an `builder` (mit Worktree-Pfad, Issue, Spec-Abschnitt). Danach pro PR die Prüfung wie in `feature-bauen` Schritt 4–8.

## 4. Zusammenführen

Gemergte PRs: Die anderen Branches rebasen (`git -C ../ballup-<issue> rebase origin/main`), Tests erneut. Konflikte löst der builder des späteren PRs.

## 5. Bericht

updater: eine gemeinsame Zeile pro Schnitt im Lagebericht.
