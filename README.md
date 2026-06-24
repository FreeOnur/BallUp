# BallerApp

Pickup basketball — courts, games, community.

**v2 restart (June 2026):** App and API code removed. This repo holds agent setup (`.claude/`, `.cursor/`, `.caliber/`), docs, design tokens, deploy scripts, and exported data. Build phases come next — see [docs/architecture/feature-plan.md](docs/architecture/feature-plan.md).

## Stack (defined, not built)

| Layer | Choice |
|-------|--------|
| Mobile | Flutter |
| API | Hono + TypeScript + Drizzle |
| Database | Postgres + PostGIS (Hetzner) |
| Auth | Custom JWT + Resend |
| Images | Backblaze B2 |

Decision: [ADR-0012](docs/decisions/0012-hono-postgres-resend-b2-backend.md)

## Docs

Start at [docs/README.md](docs/README.md).

## Deploy (when API exists)

Copy `scripts/config/deploy.example.json` → `scripts/config/deploy.json`, then `npm run deploy`. See [docs/deploy/server.md](docs/deploy/server.md).

## v1 archive

- Branch: `archive/v1-flutter-fastapi`
- Tag: `v1-flutter-fastapi-archive`
- Data: `backups/` (gitignored) + `%USERPROFILE%/Documents/BallerApp-backups/`

## Secrets

- Env: `api/.env.example` — migrate from `backups/env/backend.env.v1` ([guide](docs/deploy/env-migration.md))
- MCP: copy `.cursor/mcp.json.example` → `.cursor/mcp.json` ([rotate exposed tokens](docs/security/rotate-exposed-secrets.md))
