# BallerApp — Claude Code

Pickup basketball: court discovery, ranked games, tournaments. Repo: `FreeOnur/BallerApp`.

**v2 restart:** v1 archived on branch `archive/v1-flutter-fastapi`. **Current:** `baller_app/` + `backend/` (FastAPI interim). **Target:** Hono API in `api/` (ADR-0012).

## Stack (target — ADR-0012)

Flutter · Hono + TypeScript + Drizzle · Postgres/PostGIS · custom Auth + **Resend** · **Backblaze B2** presign

## Architecture

@./.cursor/project/architecture.md
@./.cursor/project/tech_stack.md
@./.cursor/project/product.md

| Layer | Paths |
|-------|-------|
| **Flutter** | `baller_app/` |
| **API** | `backend/app/` (interim FastAPI) · `api/src/` (target Hono): auth, courts, profiles, uploads |
| **Schema** | `backend/migrations/` · `api/drizzle/` |
| **Design** | `design/DESIGN.md` · `design/baller-design-knowledge.md` |
| **Deploy** | `scripts/deploy/` · `docs/deploy/server.md` |
| **Backups** | `backups/` (gitignored) · `docs/deploy/env-migration.md` |

## Commands

```bash
npm run deploy:check
npm run deploy:dry
npm run deploy
caliber refresh --dry-run
```

```bash
docker compose --env-file backend/.env up -d --build
curl -s http://localhost:8000/health
cd baller_app && flutter analyze
cd baller_app && flutter run --dart-define=USE_LEGACY_SUPABASE=false --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## Conventions

- **Data access**: Repository pattern (ADR-0008) — no Supabase in new code
- **Secrets**: `backend/.env` from `backend/.env.example` (interim API); `api/.env` from `api/.env.example`; migrate v1 values from `backups/env/backend.env.v1`
- **Images**: Backblaze B2 only via `POST /uploads/presign`
- **Email**: Resend for verify + password reset
- **Skills**: `hono-router` · `fastapi-router` · `repository-layer` · `auth-flow` · `setup-caliber`
- **Learnings**: `CALIBER_LEARNINGS.md`

## MCP

Copy `.cursor/mcp.json.example` → `.cursor/mcp.json` (gitignored). See `docs/security/rotate-exposed-secrets.md`.

## Docs (read first)

@./docs/README.md
@./docs/agent/context-checklist.md
@./docs/decisions/0012-hono-postgres-resend-b2-backend.md
@./docs/architecture/feature-plan.md

<!-- caliber:managed:pre-commit -->
## Before Committing

**IMPORTANT:** Before every git commit, you MUST ensure Caliber syncs agent configs with the latest code changes.

First, check if the pre-commit hook is already installed:
```bash
grep -q "caliber" .git/hooks/pre-commit 2>/dev/null && echo "hook-active" || echo "no-hook"
```

- If **hook-active**: the hook handles sync automatically — just commit normally. Tell the user: "Caliber will sync your agent configs automatically via the pre-commit hook."
- If **no-hook**: run Caliber manually before committing:
  1. Tell the user: "Caliber: Syncing agent configs with your latest changes..."
  2. Run: `caliber refresh && git add CALIBER_LEARNINGS.md CLAUDE.md .claude/ .cursor/ .cursorrules 2>/dev/null`
  3. After it completes, briefly tell the user what Caliber updated. Then proceed with the commit.

**Valid `caliber refresh` options:** `--quiet` (suppress output) and `--dry-run` (preview without writing). Do not pass any other flags — options like `--auto-approve`, `--debug`, or `--force` do not exist and will cause errors.

**`caliber config`** takes no flags — it runs an interactive provider setup. Do not pass `--provider`, `--api-key`, or `--endpoint`.

If `caliber` is not found, tell the user: "This project uses Caliber for agent config sync. Run /setup-caliber to get set up."
<!-- /caliber:managed:pre-commit -->

<!-- caliber:managed:learnings -->
## Session Learnings

Read `CALIBER_LEARNINGS.md` for patterns and anti-patterns learned from previous sessions.
These are auto-extracted from real tool usage — treat them as project-specific rules.
<!-- /caliber:managed:learnings -->

<!-- caliber:managed:model-config -->
## Model Configuration

Recommended default: `claude-sonnet-4-6` with high effort (stronger reasoning; higher cost and latency than smaller models).
Smaller/faster models trade quality for speed and cost — pick what fits the task.
Pin your choice (`/model` in Claude Code, or `CALIBER_MODEL` when using Caliber with an API provider) so upstream default changes do not silently change behavior.

<!-- /caliber:managed:model-config -->

<!-- caliber:managed:sync -->
## Context Sync

This project uses [Caliber](https://github.com/caliber-ai-org/ai-setup) to keep AI agent configs in sync across Claude Code, Cursor, Copilot, and Codex.
Configs update automatically before each commit via `caliber refresh`.
If the pre-commit hook is not set up, run `/setup-caliber` to configure everything automatically.
<!-- /caliber:managed:sync -->
