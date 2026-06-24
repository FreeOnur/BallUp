# 0011: FastAPI + Postgres + B2 (self-hosted backend)

| Field | Value |
|-------|-------|
| Status | superseded |
| Date | 2026-06-02 |
| Supersedes | 0002 (backend self-host strategy — not yet migrated to docs) |
| Superseded by | [0012](0012-hono-postgres-resend-b2-backend.md) |

## Context

ADR-0002 planned **self-hosted Supabase via Docker**. The repo now ships a **slimmer stack**: own API, own auth, external object storage — better fit for Hetzner CPX22 RAM and solo ops (optional **Coolify** for deploy UI).

Managed Supabase cost and control also motivated moving to owned infrastructure before scale.

## Decision

**Production target (Layer B backend):**

| Concern | Choice |
|---------|--------|
| API | FastAPI + Uvicorn (`backend/app/`) |
| Database | PostgreSQL + PostGIS |
| Auth | Argon2id + JWT/refresh (not Supabase Auth on cutover) |
| Images | Backblaze B2 presigned uploads (`POST /uploads/presign`) |
| Deploy | Docker Compose on Hetzner; **Coolify** optional (proxy replaces Caddy in compose) |

**Flutter:** Repository pattern ([0008-repository-pattern-for-portability](0008-repository-pattern-for-portability.md)) with `ApiClient` when `USE_LEGACY_SUPABASE=false`. Default remains legacy Supabase until cutover.

**Password migration:** Supabase password hashes are **not portable** — users reset passwords per cutover runbook (`docker-compose.yml` auth cutover section).

Production API: `https://api.ballup.net`.

## Why (reasoning)

Full self-hosted Supabase stack is RAM-heavy on a small VPS and bundles Realtime/Auth/Storage we do not all need on day one. A thin FastAPI layer gives clear ownership of schema and auth, fits CPX22, and pairs with B2 so court photos do not fill VPS disk. Coolify optional — reduces ops friction without locking into Supabase's deployment model.

## Alternatives considered

1. **Stay on managed Supabase** — simpler ops short-term; cost and less control at scale. Deferred, not primary path.
2. **Self-hosted Supabase (ADR-0002)** — heavier RAM footprint; superseded by this decision.
3. **PocketBase** — considered in earlier strategy; no longer primary path.
4. **MinIO on VPS for images** — uses limited disk; B2 presign offloads storage and bandwidth.

## Consequences

**Positive:** Lower RAM than full Supabase stack; clear ownership of auth and schema; B2 avoids VPS disk for photos.

**Negative:** No Supabase Realtime/RLS out of the box — chat/realtime needs a later decision; more custom backend work.

**Neutral:** Auth strategy (0007, OTP + Apple/Google) may need revision when Apple/Google login moves to FastAPI.

## Related

- [0008-repository-pattern-for-portability](0008-repository-pattern-for-portability.md)
- [Server deploy](../deploy/server.md)
- [Local backend](../deploy/local.md)
- `backend/README.md`, `docker-compose.yml`
- Cursor rule: `.cursor/rules/adr-0011-fastapi-postgres-b2-backend.mdc`
