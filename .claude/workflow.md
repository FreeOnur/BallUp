# Development Workflow — BallerApp (Claude Code)

Follow this workflow when using Claude Code. Rules in `.claude/rules/` and skills in `.claude/skills/` enforce it.

---

## Before Coding

1. **Read docs first** — `docs/README.md`, `docs/agent/context-checklist.md`, `docs/architecture/overview.md`.
2. **Project context** — `.cursor/project/` (`architecture.md`, `tech_stack.md`, `product.md`) via `CLAUDE.md` references.
3. **Respect rules** — `.claude/rules/` (repositories, auth, backend-api, flutter-conventions, testing-patterns).
4. **Pick the right layer** — Widget → Provider/Notifier → Repository → API/Supabase. No direct SDK calls in widgets.
5. **UI / design work** — Read `baller_app/baller-design-knowledge.md` and `baller_app/DESIGN.md`. Design in Claude Design; implement via **design-handoff** command.
6. **Analyze existing code** — Locate current logic and UI; prefer minimal, safe edits.

---

## While Coding

| Task | Use |
|------|-----|
| New API endpoint | `/fastapi-router`, `/self-hosted-backend` |
| Repository / data | `/repository-layer`, ADR-0008 |
| Auth | `/auth-flow`, `auth-conventions.md` |
| Courts / geo | `/geolocation-courts`, `/court-model` |
| Postgres schema | `/postgres-migrations` |
| Deploy / Docker | `/docker-compose-hetzner`, `npm run deploy` |
| Landing / marketing UI | `/hallmark` |
| App UI design | Claude Design + `baller_app/DESIGN.md` |
| Handoff → Flutter | **design-handoff** · `lib/design_system/components/` |
| Security review | `/security-hardening`, `.cursor/ai/security/security_checks.md` |
| Agent config sync | `/setup-caliber`, `caliber refresh` before commit |

---

## After Coding

1. **Verify** — `cd baller_app && flutter analyze` for Dart; `curl -s http://localhost:8000/health` after backend changes.
2. **Security pass** — `.cursor/ai/security/security_checks.md`.
3. **Design pass** (UI only) — Tokens from `baller-design-knowledge.md`.
4. **Update changelog** — `.cursor/ai/changes/changelog.md` if significant.
5. **Commit** — Conventional commits. Caliber pre-commit hook syncs agent configs.

---

## Design pipeline

Full guide: `.cursor/project/design-pipeline.md`

| Phase | Tool | Command / path |
|-------|------|----------------|
| Design | Claude Design | `baller_app/DESIGN.md` · **design-claude-session** |
| Handoff | Export → Claude Code | **design-handoff** · `design/handoff/` |
| Flutter code | Claude Code | **design-implement** · `lib/design_system/components/` |

---

## Reference

| Area | Path |
|------|------|
| Docs (SSOT) | `docs/` |
| Rules | `.claude/rules/` |
| Skills | `.claude/skills/` |
| Commands | `.claude/commands/` |
| Project docs | `.cursor/project/` (via `.claude/project/README.md`) |
| Cursor parity | `.cursor/workflow.md` |
| Deploy scripts | `docs/scripts/README.md`, `npm run deploy` |
| Root agent doc | `CLAUDE.md` |
