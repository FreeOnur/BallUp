# Tech Stack (v2 target)

## Mobile

- **Flutter** SDK ^3.9.0
- google_maps_flutter, geolocator
- Riverpod (state), repository pattern (ADR-0008)

## Backend (planned — not built)

- **Hono** + TypeScript
- **Drizzle** ORM + Postgres **PostGIS**
- **jose** (JWT), **argon2** (passwords)
- **Resend** (email verification, password reset)
- **Backblaze B2** (presigned image uploads — only storage provider)

## Hosting

- Hetzner CPX22, Docker Compose, optional Coolify
- Domain: `api.ballup.net`

## Not in v2

- Supabase Auth / legacy `USE_LEGACY_SUPABASE`
- FastAPI Python backend (v1 archived)

See [ADR-0012](../../docs/decisions/0012-hono-postgres-resend-b2-backend.md).
