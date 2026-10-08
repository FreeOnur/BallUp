# Mitarbeiten an BallUp

## Branches

- `main` ist geschützt: kein direkter Push, Merge nur über Pull Request mit Review und grüner CI.
- Pro Aufgabe ein kurzlebiger Branch von `main`:

| Präfix | Wofür | Beispiel |
|---|---|---|
| `feat/` | Neues Feature | `feat/courts-map` |
| `fix/` | Bugfix | `fix/chat-reconnect` |
| `chore/` | Wartung, Tooling, Dependencies | `chore/bump-kotlin` |
| `docs/` | Nur Doku | `docs/adr-database` |
| `refactor/` | Umbau ohne Verhaltensänderung | `refactor/games-repository` |

## Commits – Conventional Commits

```
<typ>(<scope>): <kurze Beschreibung im Imperativ>

feat(courts): show nearby courts on map
fix(chat): reconnect websocket after network change
chore(deps): bump ktor to 3.6.0
```

- **Typen:** `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`
- **Scope:** Modulname (`courts`, `games`, …) oder Bereich (`backend`, `android`, `ios`, `shared`, `deploy`)
- Breaking Change: `feat(api)!: …` plus `BREAKING CHANGE:` im Body

## Pull Requests

1. Klein halten (ideal < 400 geänderte Zeilen), ein Thema pro PR.
2. PR-Titel = Conventional Commit (wird beim Squash-Merge zur Commit-Message).
3. Template ausfüllen, bei UI/Animationen Screenshots oder Videos anhängen.
4. Mindestens ein Review (siehe `.github/CODEOWNERS`), CI muss grün sein.
5. **Squash and merge**, Branch danach löschen.

## Regeln

- Keine Secrets im Repo – nur `.env.example`. Echte Werte in `.env` (ignoriert) oder GitHub Secrets.
- API-Änderungen immer zusammen mit `contracts/openapi.json`.
- Neue Repo-/Build-Entscheidung → ADR in `docs/adr/` (Vorlage `0000-template.md`).
  Produkt- und Stack-Entscheidungen → Notion.
- Vor dem Push: `uv run ruff check . && uv run mypy` (Backend), `./gradlew spotlessApply check` (Mobile).
