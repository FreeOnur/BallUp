#!/usr/bin/env bash
# Follows the container logs on the server (Ctrl+C to stop).
#   logs.sh          – all services
#   logs.sh api      – one service
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

remote_tty "cd '${REMOTE_DEPLOY_DIR}/compose' \
  && BALLUP_API_IMAGE=\"\$(cat .api-image 2>/dev/null || echo unused)\" \
     docker compose -f compose.yml -f compose.observability.yml logs -f --tail=100 ${1:-}"
