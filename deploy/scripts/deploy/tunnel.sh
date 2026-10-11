#!/usr/bin/env bash
# Opens an SSH tunnel to a service that only listens on the server's loopback (Ctrl+C closes it).
#   tunnel.sh status    – Uptime Kuma admin UI on http://localhost:3001
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

case "${1:-status}" in
  status) PORT=3001 ;;
  *) echo "usage: tunnel.sh status"; exit 1 ;;
esac

echo "open http://localhost:${PORT} in your browser (Ctrl+C closes the tunnel)"
ssh -N -L "${PORT}:127.0.0.1:${PORT}" "${SSH_OPTS[@]}" "${BALLUP_SERVER}"
