#!/usr/bin/env bash
# Switches the API back to an image that was pushed before (no build).
#   rollback.sh <tag>      e.g. rollback.sh 1e45062
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

TAG="${1:-}"
if [[ -z "${TAG}" ]]; then
  echo "usage: rollback.sh <tag>   (tags: https://hub.docker.com/r/${BALLUP_IMAGE_REPO#docker.io/}/tags)"
  exit 1
fi

remote "bash '${REMOTE_DEPLOY_DIR}/scripts/server/pull.sh' api '${BALLUP_IMAGE_REPO}:${TAG}'"
