# Development Workflow — BallerApp

Follow this workflow when using AI or making changes. Rules in `.cursor/rules/` and skills in `.cursor/skills/` enforce it.

---

## Before Coding

1. **Read project context** — `.cursor/project/` (`architecture.md`, `tech_stack.md`, `product.md`) and `.cursor/ai/context/project_context.md`.
2. **Respect always-on rules** — `global.mdc`, `00-baller-tokens-always.mdc`, stack rules (`stack-flutter`, `stack-riverpod`, `stack-fastapi-baller-backend`), ADRs (`adr-0008`, `adr-0011`), `security-baseline.mdc`, `clean-code-checklist.mdc`.
3. **Pick the right layer** — Widget → Provider/Notifier → Repository → API/Supabase. No direct SDK calls in widgets (see `repositories.mdc`).
4. **UI / design work** — Read `design/baller-design-knowledge.md` and `design/DESIGN.md`. Design in **[Claude Design](https://claude.ai/design)**; implement via `/design-handoff`. Auto rules `10–40-baller-*` apply to matching globs. Manual: `@50-baller-design-audit-manual`, `@hallmark` (marketing only).
5. **Analyze existing code** — Locate current logic and UI; prefer minimal, safe edits. Ask before large refactors.

---

## While Coding

| Task | Use |
|------|-----|
| New API endpoint | `.cursor/skills/fastapi-router`, `.cursor/skills/self-hosted-backend` |
| Repository / data | `.cursor/skills/repository-layer`, `adr-0008` |
| Auth | `.cursor/skills/auth-flow`, `auth-conventions.mdc` |
| Courts / geo | `.cursor/skills/geolocation-courts`, `.cursor/skills/court-model` |
| Postgres schema | `.cursor/skills/postgres-migrations` |
| Deploy / Docker | `.cursor/skills/docker-compose-hetzner` |
| Landing / marketing UI | `@hallmark` or `.cursor/skills/hallmark` |
| App UI design | [Claude Design](https://claude.ai/design) + `design/DESIGN.md` |
| Handoff → Flutter | `/design-handoff` · `lib/design_system/components/` |
| Security review | `.cursor/skills/security-hardening`, `.cursor/ai/security/security_checks.md` |
| Agent config sync | `caliber refresh` before commit (see `caliber-pre-commit.mdc`) |

---

## After Coding

1. **Verify** — `cd baller_app && flutter analyze` for Dart changes; `curl -s http://localhost:8000/health` after backend changes.
2. **Security pass** — Run checklist in `.cursor/ai/security/security_checks.md` (auth, validation, secrets, RLS/JWT, logging).
3. **Design pass** (UI only) — Tokens from `baller-design-knowledge.md`; no Material-default slop. Optional: `@50-baller-design-audit-manual`.
4. **Update changelog** — Append to `.cursor/ai/changes/changelog.md`: file(s), reason, impact.
5. **Store prompt** (significant AI work) — Append summary to `.cursor/ai/prompts/prompt_history.md`.
6. **Commit** — Conventional commits (`conventional-commits.mdc`). Caliber pre-commit hook syncs agent configs automatically.

---

## Design pipeline (Pencil → Flutter)

Full guide: `.cursor/project/design-pipeline.md`

| Phase | Tool | Command / path |
|-------|------|----------------|
| Design | [Claude Design](https://claude.ai/design) | `design/DESIGN.md` · `/design-claude-session` |
| Handoff | Export → Claude Code | `/design-handoff` · `design/handoff/` |
| Flutter code | Cursor | `/design-implement` · `lib/design_system/components/` |

Pages compose **only** from `design_system/components/` — no ad-hoc styling in `pages/`.

---

## Reference

| Area | Path |
|------|------|
| Rules | `.cursor/rules/` |
| Skills | `.cursor/skills/` |
| Slash commands | `.cursor/commands/` |
| Project docs | `.cursor/project/` |
| Design pipeline | `.cursor/project/design-pipeline.md` |
| Pencil design files | `baller_app/design/` (Claude Design handoffs) |
| Flutter design system | `baller_app/lib/design_system/` |
| Design tokens | `design/baller-design-knowledge.md` |
| Security checklist | `.cursor/ai/security/security_checks.md` |
| PR quality CI | `.github/workflows/pr-quality.yaml` (`peakoss/anti-slop@v0`) |
| Root agent doc | `CLAUDE.md` |