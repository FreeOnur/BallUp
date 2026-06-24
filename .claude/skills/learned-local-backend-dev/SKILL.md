---
name: learned-local-backend-dev
description: Start BallerApp FastAPI+PostGIS locally for Flutter API-mode emulator dev on Windows.
---
# Local backend + Flutter emulator

## Preconditions

- Docker Desktop running (Windows: start `Docker Desktop.exe` before compose).
- `backend/.env` exists (`cp backend/.env.example backend/.env`).

## Start stack (repo root)

```bash
docker compose --env-file backend/.env up -d --build
curl -s http://localhost:8000/health
```

Expected: `{"status":"ok",...}`

## Port publishing trap

Base `docker-compose.yml` uses `expose: 8000` only (production/Coolify). Local dev needs a **gitignored** `docker-compose.override.yml`:

```yaml
services:
  api:
    ports:
      - "8000:8000"
```

Without it, compose may start but host/emulator cannot reach the API.

## Env-file trap

Compose interpolates `${POSTGRES_*}` and `${JWT_SECRET}` from the shell environment or a root `.env`. This repo keeps secrets in `backend/.env` — always pass `--env-file backend/.env`. Blank vars → `db` unhealthy.

## Flutter (Android emulator, local API)

```bash
cd baller_app && flutter run \
  --dart-define=USE_LEGACY_SUPABASE=false \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## Flutter (hosted production API)

```bash
cd baller_app && flutter run \
  --dart-define=USE_LEGACY_SUPABASE=false \
  --dart-define=API_BASE_URL=https://api.ballup.net
```

## Verify DB migrations

```bash
docker exec ballerapp-db-1 psql -U baller -d baller -c "\dt"
```

## Stop

```bash
docker compose down        # stop
docker compose down -v     # stop + wipe DB (dev only)
```