#!/usr/bin/env bash
# Build + push the API image, sync the deploy files and restart on the server.
#   deploy.sh api   – only the API (and Redis, if it is not running yet)
#   deploy.sh all   – the whole stack including Caddy and observability
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

SERVICE="${1:-api}"
case "${SERVICE}" in
  api|all) ;;
  *) echo "usage: deploy.sh [api|all]"; exit 1 ;;
esac

TAG="$(image_tag)"
"${SCRIPT_DIR}/push.sh"
"${SCRIPT_DIR}/sync.sh"
remote "bash '${REMOTE_DEPLOY_DIR}/scripts/server/pull.sh' '${SERVICE}' '${BALLUP_IMAGE_REPO}:${TAG}'"
