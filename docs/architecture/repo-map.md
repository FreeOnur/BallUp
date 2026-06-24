# Repository Map

Quick path reference for BallerApp v2. v1 code lives on branch `archive/v1-flutter-fastapi`.

## Flutter app (`baller_app/` — not built yet)

Will contain: `lib/main.dart`, `lib/auth/`, `lib/repositories/`, `lib/pages/`, `lib/core/api/`.

## Backend (`api/` — not built yet)

| What | Path (planned) |
|------|----------------|
| Hono entry | `api/src/index.ts` |
| Routes | `api/src/routes/` |
| Drizzle schema | `api/src/db/schema.ts` |
| Migrations | `api/drizzle/` |
| Env template | `api/.env.example` |

## Design (`design/`)

| What | Path |
|------|------|
| Design tokens | `design/DESIGN.md` |
| Design knowledge | `design/baller-design-knowledge.md` |

## Root / infra

| What | Path |
|------|------|
| Deploy docs | `docs/deploy/server.md` |
| Env migration | `docs/deploy/env-migration.md` |
| Deploy scripts | `scripts/deploy/` |
| Root README | `README.md` |
| Playwright e2e | `package.json` |

## Agent & docs

| What | Path |
|------|------|
| Docs (SSOT) | `docs/` |
| Cursor rules | `.cursor/rules/` |
| Cursor skills | `.cursor/skills/` |
| Claude config | `.claude/`, `CLAUDE.md` |
| Caliber | `.caliber/`, `.caliberignore` |
| Caliber learnings | `CALIBER_LEARNINGS.md` |
| Shared hooks | `scripts/hooks/` |

## Backups (gitignored)

| What | Path |
|------|------|
| DB dumps | `backups/baller-data-*.sql` |
| Env snapshot | `backups/env/backend.env.v1` |
| External copy | `%USERPROFILE%/Documents/BallerApp-backups/` |

## v1 archive

| What | Path / ref |
|------|------------|
| Git branch | `archive/v1-flutter-fastapi` |
| Git tag | `v1-flutter-fastapi-archive` |
