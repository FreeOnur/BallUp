---
name: learned-b2-presign-uploads
description: Two-step Backblaze B2 uploads in API mode: POST /uploads/presign then bare-Dio PUT to presigned URL.
---
# B2 presigned uploads (API mode)

## When to use

- Avatar or court image uploads when `USE_LEGACY_SUPABASE=false`
- Hosted backend (`https://api.ballup.net`) with `B2_*` vars set in `backend/.env`
- Legacy Supabase Storage path stays in `UploadRepository` when `USE_LEGACY_SUPABASE=true`

## Server contract (`backend/app/routers/uploads.py`)

1. `POST /uploads/presign` (Bearer JWT required)
2. Request body:
   - `filename` (required)
   - `kind`: `"avatar"` or `"court_image"`
   - `court_id`: required when `kind` is `"court_image"`
3. Response: `{ upload_url, storage_path, public_url }`
4. 503 if `B2_KEY_ID`, `B2_APP_KEY`, `B2_BUCKET` are missing on the server

## Flutter implementation pattern

Use `UploadRepository` wired through `RepositoryProvider.uploads` — do not call Supabase Storage or edge functions in API mode.

```dart
// Step 1: presign via ApiClient (Bearer attached automatically)
final presign = await _apiClient.dio.post('/uploads/presign', data: {
  'filename': filename,
  'kind': kind,
  if (courtId != null) 'court_id': courtId,
});

// Step 2: PUT bytes directly to B2 — separate bare Dio instance
await _rawDio.put(
  uploadUrl,
  data: bytes,
  options: Options(
    headers: {Headers.contentLengthHeader: bytes.length},
    contentType: contentType,
  ),
);

// Step 3: persist public_url (avatar_url on profile, or court image record)
return publicUrl;
```

## Common traps

- **Do not** use `ApiClient.dio` for the PUT — it rewrites the URL to `API_BASE_URL` and attaches a Bearer token B2 rejects.
- **Do not** probe `/uploads/presign` with GET — expect 405; use POST with auth.
- Import clash: `import 'package:supabase_flutter/supabase_flutter.dart' hide Headers;` when using Dio `Headers`.
- Local Docker often lacks B2; production container may have it — ask which backend before disabling uploads.

## Profile onboarding gotcha

Register creates a profile row with empty `username`. `hasProfile()` must check non-empty username, not row existence alone.

## Auth gotcha when switching backends

Stale JWTs after changing `API_BASE_URL` cause 401 on `/profiles/me`. `AuthGate` should sign out on 401/403 instead of spinning forever.

# B2 presigned uploads (API mode)

## When to use

API mode (`USE_LEGACY_SUPABASE=false`) with a backend that has `B2_*` env vars set (production `api.ballup.net`; usually not local Docker).

## Two-step flow

1. Authenticated `POST /uploads/presign` via `ApiClient` with body `{ filename, kind, court_id? }`.
2. Unauthenticated `PUT` file bytes to returned `upload_url` via a **bare** `Dio` instance (not `ApiClient`).
3. Persist returned `public_url` (e.g. `avatar_url` via `ProfileRepository.put /profiles/me`).

## Kind values

- `avatar` — no `court_id` required
- `court_image` — `court_id` required

## Court images: presign is not enough

Uploading bytes to B2 via presign does **not** create a DB row. `create_map_window.dart` still inserts into `court_images` via Supabase in legacy mode. For API mode you need:

1. `UploadRepository.uploadCourtImage(file, courtId)` for the B2 upload
2. A **new FastAPI route** to insert the `court_images` row (none exists yet in `backend/app/routers/`)

Do not assume `/uploads/presign` alone completes court image submission.

## Import gotcha

When importing both `dio` and `supabase_flutter`, hide Supabase's `Headers`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart' hide Headers;
```

## Local vs production

- Local compose: `B2_*` often empty → presign returns 503
- Production `api.ballup.net`: B2 configured → use for realistic upload testing