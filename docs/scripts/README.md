# Node Scripts

Repo-root Node scripts (ESM, Node ≥20). Run via `npm run <script>` from repo root.

**v2 note:** Deploy scripts target `docker-compose.yml` at repo root (to be added with `api/` service). Until then, `deploy:check` can still verify `healthUrl` if production API is up.

## Setup

```bash
cp scripts/config/deploy.example.json scripts/config/deploy.json
```

Edit `scripts/config/deploy.json` with your server details. **Never commit `deploy.json`**.

## Available commands

| npm script | Script | Description |
|------------|--------|-------------|
| `npm run deploy` | `scripts/deploy/pull-and-redeploy.mjs` | Git pull + docker compose rebuild + health check |
| `npm run deploy:check` | same + `--check-only` | Fetch/check git + health, no rebuild |
| `npm run deploy:dry` | same + `--dry-run` | Print planned commands |

## Config reference (`deploy.example.json`)

| Field | Description |
|-------|-------------|
| `mode` | `local`, `ssh`, or `coolify-webhook` |
| `composeFile` | Default `docker-compose.yml` (v2 Hono stack when added) |
| `healthUrl` | Production: `https://api.ballup.net/health` |
| `deployPath` | Absolute path to repo on Hetzner/Coolify |

See [server deploy](../deploy/server.md) and [env migration](../deploy/env-migration.md).

## Caliber hooks

Shared hook scripts live in `scripts/hooks/` (referenced from `.cursor/hooks.json` and `.claude/hooks/`).

## Adding scripts

1. Create `scripts/<name>/your-script.mjs`
2. Register in root `package.json` and `scripts/index.mjs`
3. Document here

See also `scripts/README.md`.
