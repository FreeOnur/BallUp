# Local Development (v2 — planned)

> **Current state:** No `docker-compose.yml` or `api/` in repo. Use this when the backend is scaffolded.

## Prerequisites

- Docker Desktop
- Node ≥20 (for API)
- Flutter SDK ^3.9.0 (for app, when created)

## Env setup

1. Copy v1 values: see [env-migration.md](env-migration.md) (`backups/env/backend.env.v1` → `api/.env`)
2. Or start fresh from `api/.env.example`

## Start stack (when available)

```powershell
docker compose up -d --build
curl -s http://localhost:3000/health
```

## Flutter emulator (when app exists)

```powershell
cd baller_app
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## Data restore

Import from `backups/baller-data-*.sql` after schema is created. Export row counts documented in [env-migration.md](env-migration.md).

## v1 local dev

Checkout `archive/v1-flutter-fastapi` for FastAPI + port 8000 workflow.
