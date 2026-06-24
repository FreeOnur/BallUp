# Architecture Principles (v2)

- **Repository pattern** — Widget → Notifier → Repository → Hono API (ADR-0008)
- **Feature-first Flutter** structure (when app is built)
- **Custom auth** — JWT + Resend; no Supabase client in new code
- **Backblaze B2** — all court/profile images via server presign
- **Self-hosted Postgres** — PostGIS for geo when needed
- **Design system** — tokens in `design/`; no Material-default slop

## Current repo state

Agent config, docs, scripts, and design tokens only. `baller_app/` and `api/` are empty/planned.

v1 archive: branch `archive/v1-flutter-fastapi`.
