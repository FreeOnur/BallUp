# Sitzungen

Kurzes Gedächtnis zwischen den Sitzungen. Wird von jeder Sitzung **zuerst** gelesen, damit nicht der ganze Kontext neu geladen werden muss. Neueste oben, höchstens 5 Einträge (ältere löschen, Git hat die Historie). Je Eintrag höchstens 8 Zeilen.

Vorlage:

```
## TT.MM.JJJJ – <Thema in 3–6 Wörtern>
**Gemacht:** <PRs/Issues, kurz>
**Stand:** <wo wir stehen>
**Offen / wartet auf Onur:** <Frage-Issues>
**Als Nächstes:** <1–3 Punkte>
```

## 12.11.2026 – Agent-Team, erste Features

**Gemacht:** 121 Issues aus Notion (#76–#196) · Agent-Team mit 13 Rollen und 6 Skills (#197–#199) · Force-Update im Backend (#202, Teil von #160) · ADR 0021 (#212) · certifi-Sicherheitsupdate (#211) · Regeln „Nur das Nötigste“ (#210), Modellwahl nach Aufwand, dieses Sitzungs-Log
**Stand:** `main` grün. Doku auf `main` nur per `docs(team):`-PR (geschützt).
**Offen / wartet auf Onur:** #206 Zählt Doku zur 400-Zeilen-Grenze? · #201 Lücken im Profil
**Als Nächstes:** #160 M1 braucht zuerst das Ktor-Grundgerüst in `mobile/shared/core/network` · API-Image nach certifi-Update neu bauen und deployen (Onur) · nächste Story über `naechster-schritt`
