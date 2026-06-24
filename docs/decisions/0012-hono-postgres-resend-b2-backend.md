# 0012: Hono + Postgres + Resend + Backblaze B2 (v2 backend)

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-06-24 |
| Supersedes | [0011](0011-fastapi-postgres-b2-backend.md) |
| Superseded by | — |

## Context

BallerApp v1 shipped a FastAPI backend (`backend/`) alongside a partial Flutter cutover from Supabase. A full restart (June 2026) keeps the product vision but rebuilds app and API from scratch with clearer solo-dev ergonomics and email-first auth.

Constraints: self-host on Hetzner CPX22, Postgres + PostGIS for courts/geo, **Backblaze B2** for all image storage (no VPS disk for photos), confirmation emails via **Resend**, Flutter mobile client.

## Decision

**v2 production stack (defined — implementation deferred):**

| Concern | Choice |
|---------|--------|
| Mobile | Flutter (fresh `baller_app/` when built) |
| API | **Node + Hono** (TypeScript) in `api/` |
| ORM / migrations | **Drizzle** |
| Validation | **Zod** |
| Database | **PostgreSQL + PostGIS** (Docker on Hetzner) |
| Auth | **Custom** — Argon2id passwords, JWT access + refresh (`jose`), email verification + password reset |
| Email | **Resend** (replaces SMTP env vars from v1) |
| Images | **Backblaze B2** presigned uploads (`POST /uploads/presign`) — **100% B2, no MinIO/S3 alternatives** |
| Deploy | Docker Compose + optional Coolify; `scripts/deploy/` |
| Flutter data access | Repository pattern ([0008](0008-repository-pattern-for-portability.md)) — no direct DB/Supabase in widgets |

**Not in v2:** Supabase Auth, legacy `USE_LEGACY_SUPABASE` flag, FastAPI backend.

## Why (reasoning)

- **Hono + TypeScript:** Lightweight on CPX22 RAM; large ecosystem for JWT, Argon2, Resend SDK, and B2 S3-compatible presign; faster iteration than Go for a solo dev.
- **Resend:** Transactional email (verify, reset) without self-hosting SMTP; simple API vs v1 empty SMTP placeholders.
- **Backblaze B2:** Already chosen in v1; cheapest durable object storage; keeps VPS disk free for Postgres only.
- **Flutter retained:** Cross-platform mobile, maps/geolocation investment; design system preserved in `design/`.
- **Custom auth:** Full control on Hetzner; no Supabase lock-in; fits confirmation-email flow.

## Alternatives considered

1. **Keep FastAPI (0011)** — working v1 code but user chose full rethink; Python split from planned TS tooling.
2. **Dart Frog** — shared language with Flutter; smaller auth/email/B2 ecosystem.
3. **Managed Supabase** — faster bootstrap; conflicts with self-host + custom auth goal.
4. **MinIO on VPS** — uses limited disk; rejected in favor of B2.

## Consequences

**Positive:** Single language (TS) on server; Resend simplifies email; B2 unchanged; clean break from legacy Supabase path.

**Negative:** Realtime/chat not included — needs a future ADR; full backend + app build is multi-session work.

**Neutral:** v1 data exported to `backups/`; env mapping documented in `docs/deploy/env-migration.md`.

## Related

- [0008: Repository pattern](0008-repository-pattern-for-portability.md)
- [0011: FastAPI backend](0011-fastapi-postgres-b2-backend.md) (superseded)
- [Env migration](../deploy/env-migration.md)
- [Feature plan](../architecture/feature-plan.md)
- Archive: branch `archive/v1-flutter-fastapi`, tag `v1-flutter-fastapi-archive`
