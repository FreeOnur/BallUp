# AI Context Checklist (Before Coding)

Use this checklist instead of scanning the entire repo. Target time: ~5 minutes.

## 1. Read docs index

- [ ] `docs/README.md`
- [ ] `docs/decisions/README.md` — open [ADR-0012](../decisions/0012-hono-postgres-resend-b2-backend.md) for current stack
- [ ] `docs/architecture/overview.md`
- [ ] `docs/architecture/feature-plan.md` (pre-build scope)
- [ ] `docs/architecture/repo-map.md` (if touching unfamiliar paths)

## 2. Identify task type → load skill

| Task | Skill |
|------|-------|
| New API endpoint (v2) | `hono-router` |
| Repository / data access | `repository-layer` |
| Auth flow | `auth-flow` |
| Postgres schema | `postgres-migrations` |
| Courts / geo | `geolocation-courts`, `court-model` |
| Deploy / Docker | `docker-compose-hetzner` |
| Security review | `security-hardening` |
| App UI design | `design/DESIGN.md` + design pipeline |
| Marketing UI | `hallmark` |

Skills live in `.cursor/skills/` and `.claude/skills/`.

## 3. Respect architecture rules

- [ ] Repository pattern: Widget → Notifier → Repository → Hono API
- [ ] No direct Supabase/DB access in widgets
- [ ] **Backblaze B2** for images (presigned server-side only)
- [ ] **Resend** for auth emails
- [ ] Secrets never committed (`api/.env`, `.cursor/mcp.json` gitignored)
- [ ] Design tokens from `design/baller-design-knowledge.md`

## 4. Check repo state

- [ ] Is `baller_app/` or `api/` present? (May not exist yet during v2 planning phase)
- [ ] Env: `docs/deploy/env-migration.md` if wiring secrets

## 5. Plan minimal change

- [ ] Find existing code to extend — avoid duplication
- [ ] Note files to touch before editing

## After coding

- [ ] `flutter analyze` (when `baller_app/` exists)
- [ ] Health check after API changes
- [ ] Security checklist: `.cursor/ai/security/security_checks.md`
- [ ] Conventional commit message
- [ ] `caliber refresh` if agent config changed
