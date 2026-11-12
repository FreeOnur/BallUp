# Onur: wie er entscheidet

Grundlage für den **entscheider** und den **updater**. Das Repo ist öffentlich, deshalb steht hier nur, was für Produktentscheidungen nötig ist: keine privaten Daten, keine Kontaktdaten.

Quellen: Notion (BallUp, Business Model, Geschäftsmodell, Technical Planning, Design → Decisions DEC-001 bis DEC-014), ADRs in `docs/adr/`, Arbeitsaufträge an Claude (Oktober/November 2026). Stand: 12.11.2026.

## Rolle

Co-Founder von BallUp (mit Maurice Vonbrül). Entscheidet über Produkt, Design, Technik und Geld. Baut selbst mit, gibt aber viel an KI-Agents ab.

## Werte für Entscheidungen

**Sicherheit > zuverlässig > einfach > schnell > billig.** (Auftrag vom 11.11.2026)

## So entscheidet er (beobachtet)

| Bereich | Muster | Beleg |
|---|---|---|
| Sicherheit | Hart. Root-Login aus, nur Keys, fail2ban, Firewall nur 22/80/443, keine Secrets im Repo, eigene Auth statt Fremdanbieter | ADR 0010, Notion Security, Server-Härtung Nov 2026 |
| Technik | Selbst hosten, wenig Fremddienste, eine Sache richtig statt viele halb. Hetzner + Docker + Caddy, Deploy per Skript statt CI | ADR 0002, 0016, 0018 |
| Kosten | Kostenbewusst, nimmt den günstigen Weg, wenn er nicht unsicherer ist (z. B. kleiner Server jetzt, später hochskalieren). Gratis-Kontingente gern | Notion Business Model, Stack |
| Geschäft | **No-Gos:** keine Werbung als Hauptmodell, kein Verkauf von Nutzerdaten, keine Kernfunktion hinter der Bezahlschranke. Premium nur für KI-Training | Notion Geschäftsmodell, Business Model |
| Design | Will einen eigenen, „tuffen“ Look, nichts, was nach KI oder Baukasten aussieht. Verwirft „zu brav“, „zu glatt“. 2000er Streetball/Hip-Hop/Graffiti. Entscheidet Design **selbst** | DEC-002, DEC-005, DEC-009, DEC-013, DEC-014 |
| Jugendschutz | Ernst: 14–17 ohne Swipe, ohne DMs von Fremden, ohne genauen Standort | Notion Security |
| Arbeitsweise | Gibt große Aufträge und viel Freiheit („entscheide alles selber“), will aber informiert werden und Probleme ehrlich hören. Kurze Antworten, wenig Fachchinesisch | Aufträge Nov 2026 |
| Antworten | Antwortet sehr knapp, oft nur „ok los“. Liest lange Texte ungern | Auftrag 12.11.2026 |
| Freigaben | Docs und kleine Sachen dürfen ohne ihn auf `main`. Bei Wichtigem will er gefragt werden, gern gesammelt | Auftrag 11.11.2026 |
| Freigaben | Folgt guten Empfehlungen ohne Rückfrage (#202: vorgelegt mit Empfehlung A, er hat selbst gemergt). Will, dass das Team offene Aufgaben ohne Einzelfreigabe abarbeitet („lass alles machen“) | Auftrag 12.11.2026 |
| Prozess | Agent-Regeln anpassen, Review-Threads auflösen: sollen Agents selbst machen, nicht ihm vorlegen („keine Zeit dafür“) | Auftrag 12.11.2026 |
| Umfang | Nur das Nötigste, kleinste einfache Lösung (50 statt 250 Zeilen). Nichts Ungefragtes, Extras erst kurz fragen | Auftrag 12.11.2026, `CLAUDE.md` |
| Kosten | Fleißarbeit mit billigem Modell, Aufwendiges mit dem stärksten Modell und geplant. Wenig Token: kurzes Sitzungs-Log statt alles neu lesen | Auftrag 12.11.2026 |
| Nebenprojekte | Dort „entscheide alles selber“, auch Design: clean und stark, Humor ja, Insider-Humor nein. Nur Gratis-Lösungen. Will damit Geld verdienen (Spenden). Gilt nicht für BallUp | Auftrag 12.11.2026 |

## Wie er Infos haben will

- Deutsch, locker, kurz. Erst das Ergebnis, dann Details.
- Probleme klar sagen, nicht verstecken.
- Fragen mit 2–3 Optionen und einer Empfehlung, damit er nur noch wählen muss.

## Was der entscheider daraus ableitet

- Zwischen zwei sicheren Lösungen: die einfachere, auch wenn sie etwas mehr kostet.
- Neue externe Dienste: nur, wenn es keinen selbst gehosteten Weg mit vertretbarem Aufwand gibt. Sonst Frage an Onur.
- Alles Visuelle: nie selbst festlegen (designer fragt).
- Doku, Prozess, Agent-Regeln, Review-Threads, kleine Fixes: selbst machen, im Log oder Sitzungs-Log melden, nicht fragen.
- Sein Vertrauen („lass alles machen“, #202) lockert **keine** „nie“- oder „vorlegen“-Regel aus `entscheider.md`. Vorlegen bleibt Pflicht, nur kürzer.
- Fragen an ihn: eine Zeile Frage, eine Empfehlung, so gestellt, dass „ok“ eindeutig ist.
- Umfang im Zweifel kleiner. Was nicht im Auftrag steht (Refactoring, Extra-Feature): erst fragen.
- Kostet etwas Geld: nie. Gratis-Dienst für BallUp: Frage (selbst hosten zuerst, Kostengrenze noch offen).

## Lücken (Fragen an Onur, beim ersten Lagebericht gestellt)

- [ ] Darf **Maurice** Fragen mit Label `frage-an-onur` stellvertretend beantworten?
- [ ] Reicht die **GitHub-Benachrichtigung** als Kanal, oder zusätzlich E-Mail/anderer Kanal?
- [ ] Gibt es eine **Kostengrenze pro Monat**, unter der Agents ohne Frage einen Gratis-Dienst einbinden dürfen (z. B. 0 € = nur Gratis)?
- [ ] Sprache für **Code-Kommentare und Commit-Texte**: Englisch (wie bisher bei Commits) oder Deutsch?
- [ ] Darf der entscheider an **Wochenenden/in Prüfungszeiten** mergen, oder lieber sammeln?
