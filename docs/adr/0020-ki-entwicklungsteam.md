# 0020 – KI-Entwicklungsteam aus Claude-Code-Subagents

- **Status:** Akzeptiert
- **Datum:** 2026-11-12

## Kontext

BallUp hat zwei Gründer und sehr viel geplanten Umfang (103 User Stories in drei Phasen). Ein großer Teil der Arbeit wird von KI-Agents erledigt. Ohne feste Rollen und Regeln würden Agents Entscheidungen erfinden, zu große PRs bauen und Sicherheit oder Recht übersehen.

## Entscheidung

- 13 Rollen als Claude-Code-Subagents in `.claude/agents/` (Übersicht: `docs/team/agents.md`). Jede Rolle hat Auftrag, Modell, erlaubte Tools, Pflicht-Lektüre und Ausgabeformat.
- Abläufe als Skills in `.claude/skills/` (`feature-bauen`, `swarm`, `naechster-schritt`, `sicherheits-audit`, `rechts-check`, `doku-sync`).
- Der orchestrator läuft in der Hauptsitzung, weil Subagents keine Subagents starten können.
- Werte für Entscheidungen: Sicherheit > zuverlässig > einfach > schnell > billig.
- Der entscheider mergt nur grüne PRs außerhalb von Auth, Zahlung, Standortdaten, Migrationen, `deploy/`, CI und Rechtstexten. Alles andere legt er Onur vor.
- Kommunikation mit Onur über GitHub: Issue „📋 Lagebericht“ und Issues mit Label `frage-an-onur`.
- Angriffstests nur gegen die eigene App, lokal oder auf Staging.
- Ergebnisse immer in `docs/` und auf GitHub, nie nur im Chat.

## Alternativen

| Option | Warum nicht |
|---|---|
| Ein einzelner Agent für alles | Kein Vier-Augen-Prinzip, Prüfung und Bau vermischen sich |
| Bezahlte GitHub-Action für Security-Reviews | Kostet API-Guthaben (Entscheidung Onur), laut Readme nicht gegen Prompt-Injection gehärtet. Stattdessen lokal `/security-review` und freie Scanner |
| Externes Projekt-Tool statt GitHub-Issues | Noch ein Dienst. GitHub hat Issues, Labels, Benachrichtigungen schon |

## Konsequenzen

- Positiv: kleine, geprüfte PRs, nachvollziehbare Entscheidungen (`docs/team/entscheidungen-log.md`), Onur sieht den Stand ohne in Agents reinzuschauen.
- Negativ: Mehr Token-Verbrauch pro Feature (drei Prüfer). Für reine Doku-PRs reicht der dokumentierer.
- Das Repo ist öffentlich: `docs/team/onur-profil.md` enthält nur Entscheidungsmuster, Security-Funde ohne Ausnutzungs-Details.
