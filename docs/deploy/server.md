# Server Deploy (Production)

Production backend: **Coolify** on Hetzner VPS, domain **`api.ballup.net`**.

## Coolify settings

| Setting | Value |
|---------|--------|
| Base directory | repo root (empty) |
| Compose file | `docker-compose.yml` |
| Domain | `api.ballup.net` → service `api` → port `8000` → HTTPS |

## Environment variables (Coolify UI)

Set in Coolify **Environment Variables** (not in git):

- `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
- `JWT_SECRET`
- `JWT_ACCESS_MINUTES`, `JWT_REFRESH_DAYS` (optional)
- `ENVIRONMENT=production`
- `CORS_ORIGINS` (comma-separated origins)
- `B2_KEY_ID`, `B2_APP_KEY`, `B2_BUCKET`, `B2_ENDPOINT`, `B2_REGION`

DNS: A record `api` → server IP (outside Coolify).

## Services (`docker-compose.yml`)

1. **`db`** — PostGIS 16, volume `pgdata`, migrations mounted to initdb (runs **only on empty volume**)
2. **`api`** — FastAPI built from `backend/Dockerfile`, exposes port 8000 internally

Health check after deploy:

```bash
curl -sf https://api.ballup.net/health
```

Expected: `{"status":"ok","environment":"production"}` (or similar).

## Deploy with npm scripts

Configure once (see [scripts README](../scripts/README.md)):

```bash
cp scripts/config/deploy.example.json scripts/config/deploy.json
# Edit deploy.json with your host, path, and mode
```

Commands:

```bash
npm run deploy          # pull + rebuild + health check
npm run deploy:check      # git status + health only
npm run deploy:dry        # print commands without running
```

### Deploy modes

| Mode | When to use |
|------|-------------|
| `local` | Script runs **on the server** (cron-friendly) |
| `ssh` | Trigger from dev machine via SSH |
| `coolify-webhook` | POST to Coolify deploy webhook URL |

## Schema changes on existing prod DB

Init migrations in `docker-compose.yml` do **not** re-run on existing volumes. Apply manually:

```bash
docker compose exec -T db psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < backend/migrations/NNN_new.sql
```

Verify API still healthy after migration.

## Flutter (production API)

```bash
cd baller_app && flutter run \
  --dart-define=USE_LEGACY_SUPABASE=false \
  --dart-define=API_BASE_URL=https://api.ballup.net
```

## Troubleshooting

| Issue | Check |
|-------|-------|
| 502 from proxy | `docker compose ps`, API logs in Coolify |
| DB connection refused | `db` healthcheck, `DATABASE_URL` in api service |
| Empty courts | Data not imported; see `backend/scripts/export-from-supabase.md` |
| Config stale after git pull | Rebuild: `docker compose up -d --build` |

## Cron example (local mode on server)

```cron
*/15 * * * * cd /path/to/BallerApp && /usr/bin/node scripts/deploy/pull-and-redeploy.mjs --mode local >> /var/log/baller-deploy.log 2>&1
```

Use `--check-only` in cron if you only want to redeploy when git has updates (script supports this).
