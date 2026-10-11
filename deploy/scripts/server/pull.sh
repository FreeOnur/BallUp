#!/usr/bin/env bash
# Runs ON THE SERVER (called by deploy.sh / rollback.sh): pulls the images and (re)starts the stack.
#   pull.sh api [image]   – only the API; [image] pins the version, e.g. docker.io/onurballup/ballup-api:1e45062
#   pull.sh all [image]   – the whole stack including Caddy and observability
set -euo pipefail

SERVICE="${1:-api}"
IMAGE="${2:-}"
COMPOSE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../compose" && pwd)"
cd "${COMPOSE_DIR}"

if [[ ! -f .env ]]; then
  echo "ERROR: ${COMPOSE_DIR}/.env not found. Run 'npm run install:server' and fill in .env first."
  exit 1
fi

# The deployed image is remembered in .api-image, so later runs (e.g. 'all') keep the same version.
if [[ -n "${IMAGE}" ]]; then
  echo "${IMAGE}" > .api-image
fi
if [[ -f .api-image ]]; then
  export BALLUP_API_IMAGE="$(cat .api-image)"
fi

dc() {
  docker compose -f compose.yml -f compose.observability.yml "$@"
}

case "${SERVICE}" in
  api)
    dc pull api
    dc up -d api
    ;;
  all)
    dc pull
    dc up -d --remove-orphans
    # Sync publishes new directories, so bind-mounted files keep their old inode
    # inside the running container. These processes also read config only at
    # start. Recreate them or a Caddyfile / observability change never goes live.
    dc up -d --force-recreate --no-deps caddy prometheus tempo grafana
    ;;
  *)
    echo "usage: pull.sh [api|all] [image]"
    exit 1
    ;;
esac

docker image prune -f >/dev/null 2>&1 || true

echo "waiting for api health check..."
cid="$(dc ps -q api)"
for attempt in $(seq 1 45); do
  status="$(docker inspect -f '{{.State.Health.Status}}' "${cid}" 2>/dev/null || echo unknown)"
  if [[ "${status}" == "healthy" ]]; then
    echo "api healthy (${BALLUP_API_IMAGE:-from .env})"
    echo "deploy done"
    exit 0
  fi
  if [[ "${status}" == "unhealthy" || "${attempt}" -eq 45 ]]; then
    echo "ERROR: api is ${status}. Last logs:"
    dc logs --tail=50 api
    exit 1
  fi
  sleep 2
done
