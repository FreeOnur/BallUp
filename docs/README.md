# BallerApp Docs — Start Here (AI + Humans)

Central knowledge base for BallerApp. Read this index before scanning the full codebase.

## Quick start for AI agents

1. [Context checklist](agent/context-checklist.md) — 5-minute pre-coding checklist
2. [Architecture overview](architecture/overview.md) — stack, layers, conventions
3. [Repo map](architecture/repo-map.md) — where code lives
4. [Dual-agent setup](agent/dual-agent-setup.md) — Cursor + Claude Code + Caliber
5. [Decisions log](decisions/README.md) — why we chose X (read before code scan)

## Decisions

| Doc | Purpose |
|-----|---------|
| [Decisions index](decisions/README.md) | Architecture, product, ops — **why** not just **what** |
| [Decision template](decisions/_template.md) | Copy for new entries |

## Deploy & ops

| Doc | Purpose |
|-----|---------|
| [Server deploy](deploy/server.md) | Coolify/Hetzner, env vars, `npm run deploy` |
| [Local backend](deploy/local.md) | Docker Compose, health checks, data import |

## Scripts

| Doc | Purpose |
|-----|---------|
| [Scripts index](scripts/README.md) | All Node scripts and npm commands |

## Agent config (tool-specific)

| Tool | Entry |
|------|-------|
| Cursor | `.cursor/rules/global.mdc`, `.cursor/workflow.md` |
| Claude Code | `CLAUDE.md`, `.claude/workflow.md` |
| Shared project context | `.cursor/project/` (also referenced from Claude) |

## Design (authoritative tokens)

- `baller_app/DESIGN.md`
- `baller_app/baller-design-knowledge.md`

## When to update docs

Update `docs/` when architecture, deploy flow, or agent workflow changes. Run `caliber refresh` after agent config changes so Cursor and Claude stay aligned.
