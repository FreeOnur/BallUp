# Node Scripts

Repo-root Node scripts (ESM, Node ≥20). Run via `npm run <script>` from repo root.

## Setup

```bash
cp scripts/config/deploy.example.json scripts/config/deploy.json
```

Edit `scripts/config/deploy.json` with your server details. **Never commit `deploy.json`** — it may contain hostnames and paths.

## Available commands

| npm script | Script | Description |
|------------|--------|-------------|
| `npm run deploy` | `scripts/deploy/pull-and-redeploy.mjs` | Git pull + docker compose rebuild + health check |
| `npm run deploy:check` | same + `--check-only` | Fetch/check git + health, no rebuild |
| `npm run deploy:dry` | same + `--dry-run` | Print planned commands |

## CLI flags

```
node scripts/deploy/pull-and-redeploy.mjs [options]

  --mode local|ssh|coolify-webhook   Override config mode
  --check-only                       No rebuild; report git + health status
  --dry-run                          Print commands only
  --config <path>                    Config file (default: scripts/config/deploy.json)
```

## Config reference (`deploy.example.json`)

| Field | Description |
|-------|-------------|
| `mode` | `local`, `ssh`, or `coolify-webhook` |
| `repoUrl` | Git remote for initial clone |
| `branch` | Branch to deploy (default `main`) |
| `deployPath` | Absolute path to repo on server |
| `composeFile` | Compose file name (default `docker-compose.yml`) |
| `healthUrl` | URL to curl after deploy |
| `ssh.host` | VPS hostname or IP |
| `ssh.user` | SSH user |
| `ssh.keyPath` | Path to private key (optional) |
| `coolify.webhookUrl` | Coolify deploy webhook URL |

## Adding script #2, #3, …

1. Create `scripts/<name>/your-script.mjs`
2. Add npm script in root `package.json`
3. Document here with purpose, config, and examples

See also `scripts/README.md` in the scripts folder.
