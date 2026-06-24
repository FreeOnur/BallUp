# Environment Migration (v1 → v2)

v1 env lived at `backend/.env`. A snapshot is in `backups/env/backend.env.v1` (gitignored).

When you scaffold the v2 API (`api/`), create `api/.env` from `api/.env.example` and map values:

| v1 (`backend/.env`) | v2 (`api/.env`) | Notes |
|---------------------|-----------------|-------|
| `POSTGRES_USER` | `POSTGRES_USER` | Same |
| `POSTGRES_PASSWORD` | `POSTGRES_PASSWORD` | Same |
| `POSTGRES_DB` | `POSTGRES_DB` | Same |
| `DATABASE_URL` | `DATABASE_URL` | Update host if compose service name changes |
| `JWT_SECRET` | `JWT_SECRET` | Reuse — keeps existing tokens valid after import |
| `JWT_ACCESS_MINUTES` | `JWT_ACCESS_MINUTES` | Same |
| `JWT_REFRESH_DAYS` | `JWT_REFRESH_DAYS` | Same |
| `CORS_ORIGINS` | `CORS_ORIGINS` | Same |
| `ENVIRONMENT` | `ENVIRONMENT` | Same |
| `B2_KEY_ID` | `B2_KEY_ID` | Backblaze B2 — fill when keys are available |
| `B2_APP_KEY` | `B2_APP_KEY` | Backblaze B2 |
| `B2_BUCKET` | `B2_BUCKET` | e.g. `courtfinder-images` |
| `B2_ENDPOINT` | `B2_ENDPOINT` | Region-specific S3 endpoint |
| `B2_REGION` | `B2_REGION` | e.g. `us-west-002` |
| `SMTP_*` | — | **Replaced by Resend** in v2 (see ADR-0012) |
| — | `RESEND_API_KEY` | New — email verification + password reset |

## Flutter dart-defines (unchanged intent)

```text
--dart-define=API_BASE_URL=https://api.ballup.net
```

Legacy Supabase flags are removed in v2 — API-only.

## Data restore

SQL dumps: `backups/baller-data-*.sql` and external copy at `%USERPROFILE%\Documents\BallerApp-backups\`.

Row counts at export (2026-06-24): courts 0, profiles 1, court_images 0, users 1, refresh_tokens 1.
