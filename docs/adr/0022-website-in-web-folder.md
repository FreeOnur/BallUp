# 0022 – Website ballup.eu lives in `web/` in this repo

- **Status:** Accepted
- **Date:** 2026-11-13
- **Decided by:** Onur

## Context

`ballup.eu` is the public website: a landing page with a waitlist (#173), imprint, privacy policy and terms (#174), and the `/.well-known/` files for Android App Links and iOS Universal Links (ADR 0019). Today it is one placeholder page in `deploy/site/`, which Caddy serves from `/srv/site`. The site will grow, so the question was: own repository or a folder in this monorepo? It is only the website, not a web version of the app.

## Decision

- The website source lives in **`web/`** at the repo root, next to `backend/` and `mobile/`.
- It stays a **static site** (HTML, CSS, a little JS for the waitlist form). No framework until a page needs one; then a static build (e.g. Astro) whose output folder is served the same way.
- `deploy/site/` moves to `web/` (including `.well-known/`). `deploy/scripts/deploy/sync.sh` copies `web/` (or its build output) to the server; Caddy keeps serving `/srv/site`. Done as part of #173.
- The waitlist form posts to the BallUp API (no third-party form service). Legal pages are written with the `legal` agent and checked by Onur.

## Alternatives

| Option | Why not |
|---|---|
| Own repository `ballup-web` | Second repo, second CI, second set of rules for two people. The site needs the same domain, Caddy config and deploy script as the API, and the deep-link files must match the app IDs in `mobile/` |
| Website builder (Webflow, Framer, Wix) | Monthly cost, external service with user data (waitlist), design not under version control |
| Web app (Kotlin/Wasm, React) | Not needed: no web version of the app is planned |

## Consequences

- Positive: one place, one PR can change app links, site and API together; same deploy command.
- Negative / effort: the site shares the protected `main` and CI; small text changes still need a PR.
