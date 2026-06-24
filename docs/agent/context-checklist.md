# AI Context Checklist (Before Coding)

Use this checklist instead of scanning the entire repo. Target time: ~5 minutes.

## 1. Read docs index

- [ ] `docs/README.md`
- [ ] `docs/decisions/README.md` — skim index; open relevant decision(s) for **why** before code search
- [ ] `docs/architecture/overview.md`
- [ ] `docs/architecture/repo-map.md` (if touching unfamiliar paths)

## 2. Identify task type → load skill

| Task | Skill |
|------|-------|
| New API endpoint | `fastapi-router` |
| Repository / data access | `repository-layer` |
| Auth flow | `auth-flow` |
| Postgres schema | `postgres-migrations` |
| Courts / geo | `geolocation-courts`, `court-model` |
| Deploy / Docker | `docker-compose-hetzner` |
| Security review | `security-hardening` |
| App UI design | `baller_app/DESIGN.md` + design pipeline |
| Marketing UI | `hallmark` |

Skills live in `.cursor/skills/` and `.claude/skills/`.

## 3. Respect architecture rules

- [ ] Repository pattern: Widget → Notifier → Repository → API/Supabase
- [ ] No direct Supabase/Dio in widgets or pages
- [ ] Secrets never committed
- [ ] Design tokens from `baller-design-knowledge.md` (no Inter, no purple slop)

## 4. Check mode

- [ ] Legacy Supabase (`USE_LEGACY_SUPABASE=true`) or API mode (`false`)?
- [ ] If API: backend running? `curl localhost:8000/health`

## 5. Plan minimal change

- [ ] Find existing code to extend — avoid duplication
- [ ] Note files to touch before editing

## After coding

- [ ] `cd baller_app && flutter analyze` (Dart changes)
- [ ] `curl` health after backend changes
- [ ] Security checklist: `.cursor/ai/security/security_checks.md`
- [ ] Conventional commit message
- [ ] Caliber syncs on commit if hook active
