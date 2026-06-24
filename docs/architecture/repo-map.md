# Repository Map

Quick path reference for BallerApp. Use this instead of full-tree search.

## Flutter app (`baller_app/`)

| What | Path |
|------|------|
| Entry | `lib/main.dart` |
| Auth gate | `lib/auth/auth_gate.dart` |
| Auth service | `lib/auth/auth_service.dart` |
| App config | `lib/core/config/app_config.dart` |
| API client | `lib/core/api/api_client.dart` |
| Token storage | `lib/core/api/token_storage.dart` |
| Repository provider | `lib/repositories/repository_provider.dart` |
| Auth repos | `lib/repositories/*_auth_repository.dart` |
| Court repo | `lib/repositories/court_repository.dart` |
| Profile repo | `lib/repositories/profile_repository.dart` |
| Court model | `lib/models/Court.dart` |
| Map page | `lib/pages/Map/` |
| Design system | `lib/design_system/` |
| Theme tokens | `lib/theme/` |
| Design authority | `DESIGN.md`, `baller-design-knowledge.md` |
| Legacy Supabase | `lib/supabase/court_services.dart` |

## Backend (`backend/`)

| What | Path |
|------|------|
| App factory | `app/main.py` |
| Auth router | `app/routers/auth.py` |
| Courts router | `app/routers/courts.py` |
| Profiles router | `app/routers/profiles.py` |
| Uploads (B2 presign) | `app/routers/uploads.py` |
| JWT / passwords | `app/security/` |
| DB connection | `app/db.py` |
| Dependencies | `app/dependencies.py` |
| Initial schema | `migrations/001_initial.sql` |
| Dockerfile | `Dockerfile` |
| Env template | `.env.example` |

## Root / infra

| What | Path |
|------|------|
| Production compose | `docker-compose.yml` |
| Deploy docs | `docs/deploy/server.md` |
| Deploy scripts | `scripts/deploy/` |
| Root README | `README.md` |
| Playwright e2e | `package.json`, `playwright.config.*` |

## Agent & docs

| What | Path |
|------|------|
| Docs (SSOT) | `docs/` |
| Cursor rules | `.cursor/rules/` |
| Cursor skills | `.cursor/skills/` |
| Cursor commands | `.cursor/commands/` |
| Cursor project | `.cursor/project/` |
| Claude config | `.claude/`, `CLAUDE.md` |
| Caliber learnings | `CALIBER_LEARNINGS.md` (when present) |
| Shared hooks | `scripts/hooks/` |

## Data migration

| What | Path |
|------|------|
| Export guide | `backend/scripts/export-from-supabase.md` |
| Local import | `backend/scripts/import-local.ps1` |
| Courts SQL dump | `backend/scripts/courts.sql` (gitignored) |
