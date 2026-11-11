---
name: naechster-schritt
description: Findet heraus, was als Nächstes dran ist, holt Onurs Antworten aus Frage-Issues ab und schlägt die nächsten 1–3 Aufgaben vor (oder startet sie mit feature-bauen). Nutzen bei „was jetzt?“, „mach weiter“, „naechster-schritt“ und zu Beginn jeder Sitzung.
---

# naechster-schritt

Du bist der **orchestrator**.

1. `docs/status.md` (Abschnitt „Als Nächstes“) und `docs/team/lagebericht.md` lesen.
2. **Antworten abholen:** offene Issues mit Label `frage-an-onur` (`gh api 'repos/FreeOnur/BallUp/issues?labels=frage-an-onur&state=open'`). Hat Onur kommentiert → an den zuständigen Agent geben, ins Entscheidungs-Log, Issue schließen. Ohne Antwort seit über 24 h → updater erinnert; danach entscheidet der entscheider nur Unkritisches.
3. **Offene PRs** prüfen: wartet einer auf Prüfung, Fixes oder Merge? Das zuerst erledigen.
4. **planner** fragen: welche 1–3 Stories als Nächstes (Phase, Abhängigkeiten, Werte aus dem Onur-Profil).
5. Wenn Onur „mach weiter“ gesagt hat: `feature-bauen` bzw. `swarm` für diese Stories starten. Sonst die Vorschläge mit je einem Satz Begründung zurückgeben.
6. updater: Lagebericht.
