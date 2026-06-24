# Feature & Data Model Plan (v2 — pre-build)

Sketch for the structured build phase. **No code yet** — informs design and ADR-0012 implementation.

## Product phases

| Phase | Scope | Notes |
|-------|--------|-------|
| **P0 — Foundation** | Auth (register, login, verify email, reset password), profiles, court map | Resend + B2 presign |
| **P1 — Courts** | CRUD, moderation (`pending` → `approved`), images, geo search | PostGIS when needed |
| **P2 — Social** | Find players, basic messaging | Realtime TBD (later ADR) |
| **P3 — Ranked** | Ranked games, ELO | Depends on P2 |
| **P4 — Tournaments** | Brackets, marketing site | Optional `web/` (Next.js) |

## Core entities (initial)

### `users`

- `id` UUID PK
- `email` unique, verified flag
- `password_hash` Argon2id
- `created_at`

### `profiles`

- `id` FK → `users.id`
- `username`, `avatar_url` (B2 path or public URL)
- `age`, `location`, `gender`, `skill_level` (app enums)
- `updated_at`

### `courts`

- `id` UUID
- `name`, `lat`, `lng`, `address`
- `indoor`, `lights`, `has_markings`, `surface`, `hoops`
- `status` (`pending` | `approved` | `rejected`)
- `source` (`community` | `import`)
- `created_at`

### `court_images`

- `id`, `court_id` FK
- `file_path` (B2 key)
- `created_at`

### Auth tokens (server-side)

- `refresh_tokens` — hashed, expiry
- `email_verification_tokens` — single-use, expiry
- `password_reset_tokens` — single-use, expiry

## API surface (planned)

| Area | Endpoints |
|------|-----------|
| Auth | `POST /auth/register`, `/login`, `/refresh`, `/logout`, `/verify-email`, `/forgot-password`, `/reset-password` |
| Profiles | `GET /profiles/me`, `PUT /profiles/me` |
| Courts | `GET /courts`, `GET /courts/:id`, `POST /courts` |
| Uploads | `POST /uploads/presign` → B2 PUT URL |

## Flutter conventions (when built)

- Repository interface per domain (ADR-0008)
- `ApiClient` + `TokenStorage` (secure storage)
- `--dart-define=API_BASE_URL=...`
- Design tokens: `design/DESIGN.md`, `design/baller-design-knowledge.md`

## v1 data to import (when backend exists)

Export: `backups/baller-data-2026-06-24.sql`. Map v1 tables 1:1 where schema aligns; add email verification columns for existing users (mark verified or force re-verify).
