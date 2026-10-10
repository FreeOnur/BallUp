#!/usr/bin/env bash
# Shows the containers, the deployed API image and its health.
#   status.sh
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

remote "set -e
  cd '${REMOTE_DEPLOY_DIR}/compose'
  export BALLUP_API_IMAGE=\"\$(cat .api-image 2>/dev/null || true)\"
  docker compose -f compose.yml -f compose.observability.yml ps
  echo
  echo \"api image:  \${BALLUP_API_IMAGE:-<not deployed yet>}\"
  cid=\"\$(docker compose -f compose.yml -f compose.observability.yml ps -q api 2>/dev/null || true)\"
  if [ -n \"\${cid}\" ]; then
    echo \"api health: \$(docker inspect -f '{{.State.Health.Status}}' \"\${cid}\")\"
  fi"
