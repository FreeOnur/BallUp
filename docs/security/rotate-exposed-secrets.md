# Rotate Exposed Secrets

During the v1 archive snapshot, `.cursor/mcp.json` was tracked in git with **live tokens**. Treat them as compromised even if the repo is private.

## Required rotations

| Secret | Where it was exposed | Action |
|--------|----------------------|--------|
| GitHub PAT | `.cursor/mcp.json` → `github` MCP | [Revoke](https://github.com/settings/tokens) and create a new fine-grained PAT |
| Stitch API key | `.cursor/mcp.json` → `stitch` MCP | Rotate in Google Cloud / Stitch console |

## Local setup (after rotation)

1. Copy the example: `cp .cursor/mcp.json.example .cursor/mcp.json`
2. Paste your **new** tokens into `.cursor/mcp.json` (this file is **gitignored**)
3. Never commit `.cursor/mcp.json` again

## JWT / DB / B2

These were only in gitignored `backend/.env` (now backed up to `backups/env/backend.env.v1`). No rotation required unless you suspect leakage.

When the v2 `api/` backend is built, copy values per [env-migration.md](../deploy/env-migration.md).
