# 0008: Data access — Repository pattern for portability

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-06-02 |
| Supersedes | — |
| Superseded by | — |

> **THE migration-enabler decision.** Must be in place before feature #2 ships.

## Context

We accept [0011-fastapi-postgres-b2-backend](0011-fastapi-postgres-b2-backend.md) that we migrate off managed Supabase to our **FastAPI + Postgres** API (see `docs/deploy/server.md`). If feature code calls `supabase.from('games').select(...)` directly inside widgets/notifiers, that migration is a multi-week rewrite touching every feature.

The cost of building this abstraction now: a few extra files per feature. The cost of NOT building it: weeks of refactor under pressure.

## Decision

**Every data access in the app flows:**

```
Widget → Provider/Notifier → Repository (abstract interface) → Concrete Implementation
```

Concrete implementations today: Supabase or API (`ApiClient`). Swap via provider, not call sites.

```dart
// lib/features/games/domain/game_repository.dart
abstract interface class GameRepository {
  Future<List<Game>> findGamesNear({
    required double lat,
    required double lng,
    required double radiusKm,
    required GameFilters filters,
  });
  Future<void> joinGame(String gameId, {String? lockCode});
  Future<void> leaveGame(String gameId);
  Stream<Game> watchGame(String gameId);
}

// lib/features/games/data/supabase_game_repository.dart
class SupabaseGameRepository implements GameRepository { ... }

// lib/features/games/data/game_repository_provider.dart
@riverpod
GameRepository gameRepository(GameRepositoryRef ref) =>
    SupabaseGameRepository(ref.read(supabaseClientProvider));
```

A widget that calls `supabase.client.from(...)` is a **review-blocker**. CI lint check (custom analyzer rule) added to enforce.

Current repo paths: `baller_app/lib/repositories/`.

## Why (reasoning)

Backend migration is planned and non-optional. Direct SDK calls couple UI to Supabase query shapes and auth — every screen becomes a migration surface. An interface + provider lets us change **one** concrete class per feature when cutover happens. The upfront cost is small and predictable; the alternative is a rushed, error-prone rewrite under production pressure.

Repositories return domain models (`freezed`-backed), never raw `Map<String,dynamic>` — mapping belongs in the repository so widgets stay dumb.

## Alternatives considered

1. **Direct SDK calls everywhere** — fastest now, catastrophic at migration time. Rejected.
2. **GraphQL gateway in front of Supabase** — over-engineered for our scale; ops burden of running a gateway. Rejected.
3. **Service classes (procedural)** — looks like a repository but lacks the interface contract that makes swapping implementations cheap. Rejected.

## Consequences

**Positive:** Swap Supabase → self-hosted Supabase = change the concrete repository (same SDK) → done. Swap Supabase → PocketBase = write `PocketbaseGameRepository implements GameRepository`, change the provider, ship. Days, not weeks.

**Negative:** Extra files per feature; temptation to skip the abstraction "just this once."

**Neutral:** Mapping layer is part of the repository's job.

## Related

- [0011-fastapi-postgres-b2-backend](0011-fastapi-postgres-b2-backend.md)
- [Architecture overview](../architecture/overview.md)
- Skill: `repository-layer`
- Cursor rule: `.cursor/rules/adr-0008-data-access-repository-pattern-for-portability.mdc`
