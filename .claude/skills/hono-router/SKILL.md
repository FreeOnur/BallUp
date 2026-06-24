# Hono router skill (v2 — planned)

Use when implementing BallerApp API routes in `api/`.

## Stack

- **Hono** — lightweight HTTP framework
- **Drizzle** — Postgres/PostGIS ORM
- **Zod** — request validation
- **jose** — JWT sign/verify
- **argon2** — password hashing
- **Resend** — transactional email
- **@aws-sdk/client-s3** — Backblaze B2 presigned URLs (S3-compatible)

## Layout

```
api/
  src/
    index.ts          # app entry, CORS, /health
    routes/
      auth.ts
      courts.ts
      profiles.ts
      uploads.ts
    db/
      schema.ts
      client.ts
    middleware/
      auth.ts
  drizzle/
  .env.example
```

## Conventions

- One route file per domain; export Hono sub-app mounted in `index.ts`
- Validate body/query with Zod before DB access
- Auth middleware reads Bearer JWT, sets `userId` on context
- Errors: consistent JSON `{ error: string }` with appropriate HTTP status
- B2 presign: server-side only; never expose B2 keys to Flutter

## Auth flow

1. `POST /auth/register` — hash password, create user, send Resend verification email
2. `POST /auth/verify-email` — token from email link
3. `POST /auth/login` — issue access + refresh JWT
4. `POST /auth/refresh` — rotate refresh token
5. `POST /auth/forgot-password` / `reset-password` — Resend + token table

## Related

- ADR-0012: `docs/decisions/0012-hono-postgres-resend-b2-backend.md`
- Env: `api/.env.example`
- v1 archive: `archive/v1-flutter-fastapi` (FastAPI reference only)
