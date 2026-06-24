# Server Deploy (Production)

Production backend: **Coolify** on Hetzner VPS, domain **`api.ballup.net`**.

> **v2 note:** `docker-compose.yml` and `api/` are not in the repo yet. This doc describes the target deploy flow. v1 reference: branch `archive/v1-flutter-fastapi`.

## Coolify settings (when compose exists)

| Setting | Value |
|---------|--------|
| Base directory | repo root (empty) |
| Compose file | `docker-compose.yml` |
| Domain | `api.ballup.net` → service `api` → port `3000` (or as defined in compose) → HTTPS |

## Environment variables (Coolify UI)

Set in Coolify **Environment Variables** (not in git). Migrate from v1 via [env-migration.md](env-migration.md):

- `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, `DATABASE_URL`
- `JWT_SECRET`, `JWT_ACCESS_MINUTES`, `JWT_REFRESH_DAYS`
- `ENVIRONMENT=production`, `CORS_ORIGINS`
- **Backblaze B2:** `B2_KEY_ID`, `B2_APP_KEY`, `B2_BUCKET`, `B2_ENDPOINT`, `B2_REGION`
- **Resend:** `RESEND_API_KEY`, `RESEND_FROM`

DNS: A record `api` → server IP.

## Services (planned compose)

1. **`db`** — PostGIS 16, volume `pgdata`
2. **`api`** — Hono Node app built from `api/Dockerfile`

Health check:

```bash
curl -sf https://api.ballup.net/health
```

## Deploy with npm scripts

```bash
cp scripts/config/deploy.example.json scripts/config/deploy.json
npm run deploy
npm run deploy:check
npm run deploy:dry
```

See [scripts README](../scripts/README.md) for modes (`local`, `ssh`, `coolify-webhook`).

## v1 archive

FastAPI stack removed from `main`. Restore with `git checkout archive/v1-flutter-fastapi -- backend/ docker-compose.yml`.
