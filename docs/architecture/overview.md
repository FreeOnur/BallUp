# Architecture Overview

Pickup basketball app: court discovery, ranked games (planned), tournaments (planned).

## Stack

| Layer | Technology | Path |
|-------|------------|------|
| Mobile | Flutter SDK ^3.9.0 | `baller_app/` |
| Backend (target) | FastAPI + PostgreSQL/PostGIS | `backend/` |
| Compose | Docker Compose | `docker-compose.yml` (repo root) |
| Legacy (cutover) | Supabase Auth + DB | `USE_LEGACY_SUPABASE=true` |
| Object storage | Backblaze B2 presign | `POST /uploads/presign` |
| Maps / location | google_maps_flutter, geolocator | via `LocationService` |
| CI | anti-slop on PRs | `.github/workflows/pr-quality.yaml` |

Production API: `https://api.ballup.net` (Coolify on Hetzner).

## Layer model

```
Widget → Provider/Notifier → Repository → API or Supabase
```

**Rule (ADR-0008):** All new data access goes through `baller_app/lib/repositories/`. No direct `Supabase.instance.client` or raw Dio in widgets/pages.

| Layer | Path | Responsibility |
|-------|------|----------------|
| Entry | `baller_app/lib/main.dart` | BadwordFilter → AuthGate |
| Auth | `lib/auth/` | AuthGate, AuthService |
| API client | `lib/core/api/` | ApiClient, TokenStorage |
| Repositories | `lib/repositories/` | Dual-mode data access |
| Pages / widgets | `lib/pages/`, `lib/widgets/` | UI only |
| Models | `lib/models/` | fromMap / Freezed, no business logic |
| Backend routers | `backend/app/routers/` | auth, courts, profiles, uploads |
| Schema | `backend/migrations/` | SQL migrations |
| Legacy | `lib/supabase/` | Only when legacy flag is on |

## Auth modes

| Mode | Flag | Auth impl |
|------|------|-----------|
| Legacy | `USE_LEGACY_SUPABASE=true` (default) | SupabaseAuthRepository |
| Self-hosted | `USE_LEGACY_SUPABASE=false` | ApiAuthRepository + JWT |

Flutter run (API mode, Android emulator):

```bash
cd baller_app && flutter run \
  --dart-define=USE_LEGACY_SUPABASE=false \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## Conventions

- Secrets: `--dart-define` or `backend/.env` — never commit keys
- Server validation in Postgres/API — client validation is UX only
- Design: custom design system, dark default — see `baller_app/baller-design-knowledge.md`
- Commits: conventional commits (`type(scope): description`)
- Agent sync: Caliber pre-commit hook + `caliber refresh`

## AI workflow

**Before coding:** Read this doc + [context checklist](../agent/context-checklist.md) + relevant skill/rule.

**After coding:** `flutter analyze`, security checklist (`.cursor/ai/security/security_checks.md`), update changelog if significant.

## Related decisions

- [0008: Repository pattern](../decisions/0008-repository-pattern-for-portability.md)
- [0011: FastAPI + Postgres + B2 backend](../decisions/0011-fastapi-postgres-b2-backend.md)
- Full index: [docs/decisions/README.md](../decisions/README.md)

Cursor rules (enforcement mirror): `.cursor/rules/adr-0008-*.mdc`, `.cursor/rules/adr-0011-*.mdc`.
