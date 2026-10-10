#!/usr/bin/env bash
# First-time setup: copies the deploy files and creates deploy/compose/.env on the server from .env.example.
#   install.sh
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

"${SCRIPT_DIR}/sync.sh"
remote "set -e
  cd '${REMOTE_DEPLOY_DIR}/compose'
  if [ -f .env ]; then
    echo '.env already exists, left unchanged'
  else
    cp .env.example .env
    echo 'created .env from .env.example'
  fi
  chmod 600 .env"

echo "install done"
echo "next: fill in ${BALLUP_SERVER}:${REMOTE_DEPLOY_DIR}/compose/.env (npm run ssh), then npm run deploy"
