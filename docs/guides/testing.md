# Testing strategy

What we test, with which tools, how much, and when. Performance targets come from [checklists/launch-readiness.md](../checklists/launch-readiness.md) and Notion "Non-Functional-Requirements".

## The pyramid

| Level | What | Backend | Shared (KMP) | Android | iOS | Share |
|---|---|---|---|---|---|---|
| **Unit** | Logic without I/O: services, validation, mappers, ViewModels | `pytest` in `backend/tests/unit/<area>/` | `commonTest` (kotlin.test) | JUnit for ViewModels | XCTest for ViewModels | most |
| **Integration** | Real database and Redis: routers, SQL, PostGIS queries, migrations | `pytest -m integration` in `backend/tests/integration/<area>/` against `compose.dev.yml` | repository + SQLDelight with in-memory driver, Ktor `MockEngine` | – | – | some |
| **Contract** | API matches `contracts/openapi.json` | test exports the schema and compares | generated client compiles | – | – | one per change |
| **UI** | Key flows and all screen states | – | – | Compose UI tests | XCUITest | few |
| **Smoke** | Live system answers after deploy | `npm run status` + `/health` (Uptime Kuma checks every minute) | – | – | – | after each deploy |

## How much

- **Backend:** line + branch coverage ≥ **70 %** (enforced in `pyproject.toml`, CI fails below). Services ≥ 80 % in practice.
- **Shared/Android/iOS:** every ViewModel state and every repository path has a test. No coverage number until Kover/Xcode coverage is set up (#245).
- **Every bug fix** starts with a test that fails without the fix.
- **Every acceptance criterion** of a story is covered by at least one test (name the test in the spec task).
- Edge cases always: empty, offline, no permission (GPS, camera), wrong input, too old app version (`426`), expired login.
- No coverage hunting: a meaningful test beats three that only touch lines.

## When tests run

| When | What | Who |
|---|---|---|
| Before every push | Backend: `uv run ruff check . && uv run mypy && uv run pytest -m "not integration"` · Mobile: `./gradlew spotlessApply check` | developer / builder agent |
| Every PR (CI) | backend-ci (lint, types, all tests, coverage), android-ci (spotless, check, assemble), ios-ci (shared tests, framework, app build) | GitHub Actions |
| Before merge | tester, reviewer, security agents (see [team/agents.md](../team/agents.md)) | agents |
| After every deploy | smoke: `npm run status`, `https://api.ballup.eu/health` | developer |
| Before every release | performance tests (below), manual run on real devices, [release checklist](../checklists/release.md) | Onur + tester |
| Monthly | security audit (`sicherheits-audit` skill), DB restore test ([runbooks/restore.md](../runbooks/restore.md)) | agents / Onur |

## Performance

| Target (from launch-readiness) | How we measure | When |
|---|---|---|
| API p95 < 300 ms under load | **k6** script per main endpoint against staging (#221), 50 → 500 virtual users | before each release, after big backend changes |
| Courts on the map in ≤ 2 s | `EXPLAIN ANALYZE` for the bbox query (PostGIS index used), plus timing in the app | when the court query changes |
| Slow queries | `pg_stat_statements`, queries > 200 ms logged (database rules DB-68) | weekly look in Grafana |
| Cold start < 2 s, warm < 1 s | Android **Macrobenchmark** + Baseline Profiles, Xcode **Instruments** (App Launch) | before each release |
| 60 fps scrolling, no ANRs | Macrobenchmark frame timing, Instruments (Hitches) | before each release |
| Battery ≤ 5 %/h with open map | Android Battery Historian, Xcode Energy gauge, 1 h test on a mid-range phone | before the first public release |
| Download < 50 MB | store build size report | every store build |

Results go into `docs/reviews/` (template `_template.md`) so the next run can compare.

## Real devices

Before each store release, test on at least: one older Android (Android 10/11, 4 GB RAM), one current Android, one iPhone SE-size, one current iPhone. Large text (200 %), dark and light mode, screen reader once per key flow.

## Rules

- Tests are never weakened to make CI green. A failing test is fixed or the code is.
- Flaky test: fix it or mark it with an issue within the sprint; never ignore silently.
- Test data is fake. No real user data, no secrets in tests.
- Security tests only against our own app (local or staging), never production or third parties.
