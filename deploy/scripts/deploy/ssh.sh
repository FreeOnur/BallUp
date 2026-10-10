#!/usr/bin/env bash
# Opens a shell on the server in the compose directory (e.g. to edit .env).
#   ssh.sh
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

remote_tty "cd '${REMOTE_DEPLOY_DIR}/compose' && exec bash -l"
