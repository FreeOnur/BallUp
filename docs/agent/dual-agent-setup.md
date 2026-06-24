# Dual-Agent Setup (Cursor + Claude Code)

BallerApp uses **two AI agent surfaces** synced by **Caliber**. There is no single `.agent/` folder — each tool reads its own path.

## Architecture

```
docs/                    ← shared knowledge (read first)
├── architecture/
├── deploy/
├── agent/
└── scripts/

.cursor/                 ← Cursor-native config
├── rules/               ← 39 .mdc rules (always-on + glob-scoped)
├── skills/
├── commands/            ← slash commands
├── project/
└── workflow.md

.claude/                 ← Claude Code-native config
├── rules/               ← 6+ path-scoped .md rules
├── skills/
├── commands/            ← workflow prompts (adapted from Cursor)
├── hooks/
└── workflow.md

CLAUDE.md                ← Claude entry manifest (points at docs + .cursor/project)
```

## Why not one `.agent/` folder?

- **Cursor** only loads `.cursor/`
- **Claude Code** only loads `.claude/` + `CLAUDE.md`
- **Caliber** syncs overlapping content (skills, core rules) on commit
- **`docs/`** is the human + AI readable SSOT for architecture, deploy, and checklists

## Caliber workflow

1. Install: `/setup-caliber` skill or `npm install -g @rely-ai/caliber`
2. Pre-commit hook: `caliber hooks --install`
3. On commit: configs sync automatically
4. Manual refresh: `caliber refresh` (flags: `--quiet`, `--dry-run` only)

## Hook parity

| Event | Claude (`.claude/settings.json`) | Cursor (`.cursor/hooks.json`) |
|-------|----------------------------------|-------------------------------|
| Session start | Config freshness check | Same (shared script) |
| Session end | `caliber refresh` + learn finalize | refresh + finalize |
| Tool use | learn observe | learn observe |

Shared shell scripts live in `scripts/hooks/`.

## Where to add new guidance

| Content type | Put it in |
|--------------|-----------|
| Architecture, deploy, ops | `docs/` |
| Always-on coding rules | `.cursor/rules/` (Caliber may mirror to `.claude/rules/`) |
| Task playbooks | `.cursor/skills/` and `.claude/skills/` (keep in sync via Caliber) |
| Slash / command workflows | `.cursor/commands/` + `.claude/commands/` |
| Product vision / roadmap | `.cursor/project/` (referenced from Claude via `CLAUDE.md`) |

## MCP

MCP servers are configured in `.cursor/mcp.json`. Claude Code docs reference the same file.

## First session checklist

1. Read `docs/README.md`
2. Run `/setup-caliber` if pre-commit hook missing
3. Pick the right skill for the task (see `.claude/workflow.md` or `.cursor/workflow.md`)
