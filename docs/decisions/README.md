# Decisions Log

In-repo record of **why** BallerApp is built the way it is. Read this **before** scanning the codebase — it saves tokens and avoids re-deriving context from code.

**Source of truth:** `docs/decisions/` (replaces Obsidian vault for new decisions). You specify a decision; the agent creates a new markdown file from `_template.md`.

## For AI agents

1. Read this index first.
2. Open any decision that matches your task (architecture, auth, deploy, product, …).
3. Only then search code for implementation details.

## Naming

```
docs/decisions/NNNN-short-kebab-title.md
```

- `NNNN` — four-digit sequential number (0001, 0002, …)
- `short-kebab-title` — lowercase, hyphen-separated
- Covers **any** project decision (architecture, product, ops, design), not only backend

## Status values

| Status | Meaning |
|--------|---------|
| `accepted` | Current decision — follow it |
| `superseded` | Replaced by a newer decision — see "Supersedes" / "Superseded by" |
| `proposed` | Under discussion — do not treat as final |

## How to add a decision

1. Copy [`_template.md`](_template.md) to `NNNN-your-title.md` (next free number).
2. Fill in context, decision, **why** (reasoning), alternatives rejected, consequences.
3. Add a row to the index table below.
4. If this replaces an older decision, set old status to `superseded` and link both ways.

No slash command or automation — describe the decision in chat; the agent writes the file.

## Index

| # | Title | Status | Date |
|---|-------|--------|------|
| [0008](0008-repository-pattern-for-portability.md) | Repository pattern for portability | accepted | 2026-06-02 |
| [0011](0011-fastapi-postgres-b2-backend.md) | FastAPI + Postgres + B2 backend | superseded | 2026-06-02 |
| [0012](0012-hono-postgres-resend-b2-backend.md) | Hono + Postgres + Resend + B2 (v2) | accepted | 2026-06-24 |

### Pending migration (content in Obsidian vault — add when available)

| # | Title | Status | Notes |
|---|-------|--------|-------|
| 0001 | Tech stack: Flutter + Supabase | — | Not yet in repo |
| 0002 | Backend self-host strategy | superseded | Superseded by [0011](0011-fastapi-postgres-b2-backend.md) |
| 0005 | Ranked vs unranked architecture | — | Not yet in repo |
| 0007 | Auth strategy: Supabase OTP + Apple/Google | — | May need revision when auth moves to FastAPI |

## Related docs

- [Architecture overview](../architecture/overview.md)
- [Context checklist](../agent/context-checklist.md)
- Cursor rules (legacy mirror): `.cursor/rules/adr-*.mdc` — still active for enforcement; **new** decisions go here only.
