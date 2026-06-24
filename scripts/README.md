# BallerApp Node Scripts

Operational scripts runnable with Node ≥20 from repo root.

## Quick start

```bash
cp scripts/config/deploy.example.json scripts/config/deploy.json
npm run deploy:dry
npm run deploy
```

See [docs/scripts/README.md](../docs/scripts/README.md) for full reference.

## Layout

```
scripts/
  config/           deploy.json (gitignored), deploy.example.json
  lib/              shared utilities
  deploy/           pull-and-redeploy.mjs
  hooks/            shared Caliber hook scripts
  index.mjs         CLI entry (optional)
```
