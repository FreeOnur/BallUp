#!/usr/bin/env bash
# Copies the server-side files (compose, Caddy, observability, server scripts) to the server.
# The server has no git checkout; deploy/compose/.env on the server is never touched.
#   sync.sh
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

echo "syncing deploy files to ${BALLUP_SERVER}:${REMOTE_DEPLOY_DIR}..."
tar -C "${REPO_ROOT}/deploy" -cf - \
  compose/compose.yml \
  compose/compose.observability.yml \
  compose/.env.example \
  caddy \
  observability \
  scripts/server \
  | remote "set -e
    mkdir -p '${REMOTE_DEPLOY_DIR}/compose'
    cd '${REMOTE_DEPLOY_DIR}'
    rm -rf caddy observability scripts/server
    tar -xf -
    find . -name '*.sh' -exec chmod +x {} +"
echo "sync done"
