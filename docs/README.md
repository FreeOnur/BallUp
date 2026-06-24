# BallerApp Docs — Start Here (AI + Humans)

Central knowledge base for BallerApp. Read this index before scanning the full codebase.

**v2 status:** App (`baller_app/`) and API (`api/`) not built yet. Stack defined in [ADR-0012](decisions/0012-hono-postgres-resend-b2-backend.md).

## Quick start for AI agents

1. [Context checklist](agent/context-checklist.md) — 5-minute pre-coding checklist
2. [Architecture overview](architecture/overview.md) — stack, layers, conventions
3. [Repo map](architecture/repo-map.md) — where code lives
4. [Feature plan](architecture/feature-plan.md) — entities and phases (pre-build)
5. [Dual-agent setup](agent/dual-agent-setup.md) — Cursor + Claude Code + Caliber
6. [Decisions log](decisions/README.md) — why we chose X (read before code scan)

## Decisions

| Doc | Purpose |
|-----|---------|
| [Decisions index](decisions/README.md) | Architecture, product, ops — **why** not just **what** |
| [ADR-0012](decisions/0012-hono-postgres-resend-b2-backend.md) | Current backend/mobile stack |
| [Decision template](decisions/_template.md) | Copy for new entries |

## Deploy & ops

| Doc | Purpose |
|-----|---------|
| [Server deploy](deploy/server.md) | Coolify/Hetzner, env vars, `npm run deploy` |
| [Env migration](deploy/env-migration.md) | v1 → v2 env mapping (Backblaze B2, Resend) |
| [Rotate secrets](security/rotate-exposed-secrets.md) | MCP tokens exposed in git history |

## Scripts

| Doc | Purpose |
|-----|---------|
| [Scripts index](scripts/README.md) | All Node scripts and npm commands |

## Agent config (tool-specific)

| Tool | Entry |
|------|-------|
| Cursor | `.cursor/rules/global.mdc`, `.cursor/workflow.md` |
| Claude Code | `CLAUDE.md`, `.claude/workflow.md` |
| Caliber | `.caliber/`, `.caliberignore` |
| Shared project context | `.cursor/project/` (also referenced from Claude) |

## Design (authoritative tokens)

- `design/DESIGN.md`
- `design/baller-design-knowledge.md`

## When to update docs

Update `docs/` when architecture, deploy flow, or agent workflow changes. Run `caliber refresh` after agent config changes so Cursor and Claude stay aligned.
