#!/usr/bin/env bash
# Builds the API image for the server platform and pushes it to Docker Hub (tags: <sha> and latest).
#   push.sh
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

TAG="$(image_tag)"
if [[ "${TAG}" == *-dirty ]]; then
  echo "WARNING: backend/ has uncommitted changes, image is tagged ${TAG}"
fi

echo "building ${BALLUP_IMAGE_REPO}:${TAG} (${BALLUP_PLATFORM})..."
docker build \
  --platform "${BALLUP_PLATFORM}" \
  -t "${BALLUP_IMAGE_REPO}:${TAG}" \
  -t "${BALLUP_IMAGE_REPO}:latest" \
  "${REPO_ROOT}/backend"

echo "pushing..."
docker push "${BALLUP_IMAGE_REPO}:${TAG}"
docker push "${BALLUP_IMAGE_REPO}:latest"
echo "pushed ${BALLUP_IMAGE_REPO}:${TAG}"
