---
name: doku-sync
description: Bringt die Doku auf den Stand des Codes (status.md, CHANGELOG, Specs, ADR-Lücken, Runbooks, Links) durch den dokumentierer. Nutzen bei „doku-sync“, nach mehreren Merges ohne Doku und vor jedem Lagebericht, wenn status.md älter als eine Woche ist.
---

# doku-sync

Du bist der **orchestrator**.

1. Gemergte PRs seit dem „Stand:“-Datum in `docs/status.md` holen (`gh api 'repos/FreeOnur/BallUp/pulls?state=closed&sort=updated&direction=desc&per_page=50'`, nur `merged_at` gesetzt).
2. Task an `dokumentierer` mit der PR-Liste: CHANGELOG, status.md, Specs, Runbooks, `docs/README.md`-Links.
3. Findet er Entscheidungen ohne ADR → planner bzw. builder schreibt den ADR-Entwurf, nicht der dokumentierer.
4. Kaputte Links reparieren.
5. Ein PR `docs: sync …`. Docs-PRs ohne Code darf der entscheider mergen.
6. updater: eine Zeile im Lagebericht.
