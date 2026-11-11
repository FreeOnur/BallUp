---
name: sicherheits-audit
description: Monatliches Security-Audit von ganz main (oder gezielt eines Bereichs) durch den security-Agent: statische Analyse, Secrets, Abhängigkeiten, OWASP ZAP gegen die lokale API, MobSF gegen die Debug-Apps, Angreifer-Stories. Nur gegen die eigene App, lokal oder Staging. Nutzen bei „sicherheits-audit“, „prüf die Sicherheit“, einmal im Monat.
---

# sicherheits-audit

Du bist der **orchestrator**.

1. Lokale Umgebung starten (`deploy/compose`, Entwicklungs-Konfiguration). **Nie gegen Produktion.**
2. Task an `security` mit Auftrag „Monats-Audit“ (siehe Abschnitt „Einmal im Monat“ in `.claude/agents/security.md`), Bereich: ganz `main` oder der genannte Teil.
3. Parallel Task an `ops`: Backup-Prüfung nach `docs/runbooks/restore.md`.
4. Ergebnis:
   - `docs/security/reviews/<JJJJ-MM>-monat.md`
   - je Fund ein Issue mit Label `security` (kritische ohne Ausnutzungs-Details, das Repo ist öffentlich)
   - Checklisten `docs/checklists/security.md` und `security-masvs.md`: Haken setzen, wo jetzt belegt
5. Kritische oder hohe Funde → planner setzt sie in „Als Nächstes“ ganz nach oben.
6. updater: Lagebericht mit Anzahl Funde je Schwere.
