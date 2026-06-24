# Local Backend & Development

Run the FastAPI + PostGIS stack locally for API-mode Flutter development.

## Start stack

From repo root:

```bash
docker compose up -d --build
curl -s http://localhost:8000/health
```

Expected: `{"status":"ok",...}`

Open API docs: `http://localhost:8000/docs`

## Environment

Copy backend env template:

```bash
cp backend/.env.example backend/.env
```

Root `docker-compose.yml` reads `POSTGRES_*`, `JWT_SECRET`, and B2 vars from the environment (`.env` at repo root or exported vars).

## Flutter (local API, Android emulator)

```bash
cd baller_app && flutter run \
  --dart-define=USE_LEGACY_SUPABASE=false \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

| Device | API_BASE_URL |
|--------|----------------|
| Android emulator | `http://10.0.2.2:8000` |
| iOS simulator | `http://localhost:8000` |
| Physical device | `http://<your-lan-ip>:8000` |

## Legacy Supabase mode

```bash
cd baller_app && flutter run \
  --dart-define=USE_LEGACY_SUPABASE=true \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Import court data

Large SQL dump is gitignored (`backend/scripts/courts.sql`). Import via:

```powershell
cd backend/scripts && .\import-local.ps1
```

Export guide: `backend/scripts/export-from-supabase.md`

## Verify changes

```bash
cd baller_app && flutter analyze
cd baller_app && flutter test
npx playwright test
```

## Stop / reset

```bash
docker compose down        # stop
docker compose down -v     # stop + wipe DB volume (dev only)
```
