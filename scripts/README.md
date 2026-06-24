# BallerApp Node Scripts

Operational scripts (Node ≥20) from repo root.

## Quick start

```bash
cp scripts/config/deploy.example.json scripts/config/deploy.json
npm run deploy:dry
npm run deploy
```

Full reference: [docs/scripts/README.md](../docs/scripts/README.md)

## Layout

```
scripts/
  config/           deploy.json (gitignored), deploy.example.json
  lib/              config.mjs, exec.mjs, ssh.mjs
  deploy/           pull-and-redeploy.mjs
  hooks/            Caliber hook scripts (shared with .cursor/.claude)
  index.mjs         CLI entry
```

## v2 stack

Deploy assumes repo-root `docker-compose.yml` with PostGIS + Hono `api/` (not in repo yet). v1 FastAPI compose: branch `archive/v1-flutter-fastapi`.
