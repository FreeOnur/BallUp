---
paths:
  - baller_app/lib/auth/**
  - baller_app/lib/repositories/**
  - baller_app/lib/core/api/**
  - baller_app/lib/core/config/app_config.dart
---

# Auth Conventions

## AuthGate (`auth_gate.dart`)

- Root from `main.dart` → `MaterialApp(home: AuthGate())`.
- **Legacy**: `StreamBuilder` on `onAuthStateChange` → `hasProfile()` via `ProfileRepository`.
- **API**: `_ApiAuthGate` — `AuthRepository.hasSession()` → `hasProfile(userId:)` via `ProfileRepository`.
- **Profile complete**: non-empty `username` required (`hasProfile()`); register seeds empty row.
- **Stale token**: API mode 401/403 on `/profiles/me` → `signOut()` → login (not infinite spinner).
- Loading → `CircularProgressIndicator`; no session → `LoginPage(onAuthSuccess:)`; needs profile → `ProfileCreationPage(onProfileComplete:)`.

## AuthService

- Delegates to `AuthRepository` — UI must not call Supabase directly.

## Cutover

- See root `README.md` (deploy section) — passwords not portable from Supabase.
