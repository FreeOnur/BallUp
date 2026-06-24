# Architecture Overview

Pickup basketball app: court discovery, ranked games (planned), tournaments (planned).

**Status (June 2026):** v1 Flutter + FastAPI archived. Repo holds agent config, docs, and design tokens. App (`baller_app/`) and API (`api/`) are **not built yet** — see [ADR-0012](../decisions/0012-hono-postgres-resend-b2-backend.md).

## Stack (v2 target)

| Layer | Technology | Path |
|-------|------------|------|
| Mobile | Flutter SDK ^3.9.0 | `baller_app/` (to be created) |
| Backend | Hono + TypeScript + Drizzle | `api/` (to be created) |
| Database | PostgreSQL + PostGIS | Docker on Hetzner |
| Auth | Custom JWT + Resend email | `api/src/routes/auth` |
| Object storage | **Backblaze B2** presign | `POST /uploads/presign` |
| Maps / location | google_maps_flutter, geolocator | via repository layer |
| CI | anti-slop on PRs | `.github/workflows/pr-quality.yaml` |

Production API: `https://api.ballup.net` (Coolify on Hetzner).

## Layer model

```
Widget → Provider/Notifier → Repository → Hono API
```

**Rule (ADR-0008):** All data access goes through repositories. No direct DB or legacy Supabase in widgets.

## Design authority

- `design/DESIGN.md`
- `design/baller-design-knowledge.md`

## Conventions

- Secrets: `--dart-define` or `api/.env` — never commit keys
- Env migration from v1: [env-migration.md](../deploy/env-migration.md)
- Commits: conventional commits
- Agent sync: Caliber + `scripts/hooks/`

## Related decisions

- [0008: Repository pattern](../decisions/0008-repository-pattern-for-portability.md)
- [0012: Hono + Postgres + Resend + B2](../decisions/0012-hono-postgres-resend-b2-backend.md)
- [Feature plan](feature-plan.md)
