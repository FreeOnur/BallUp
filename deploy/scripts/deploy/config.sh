#!/usr/bin/env bash
# Shared settings for the deploy scripts. Every value can be overridden via environment variable.

BALLUP_SERVER="${BALLUP_SERVER:-deploy@46.224.171.6}"
BALLUP_SSH_KEY="${BALLUP_SSH_KEY:-${HOME}/.ssh/ballup_deploy}"
BALLUP_REMOTE_DIR="${BALLUP_REMOTE_DIR:-/opt/ballup}"
BALLUP_IMAGE_REPO="${BALLUP_IMAGE_REPO:-docker.io/onurballup/ballup-api}"
# The Hetzner server is x86_64; without this a Mac with Apple Silicon would build arm64 images.
BALLUP_PLATFORM="${BALLUP_PLATFORM:-linux/amd64}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
REMOTE_DEPLOY_DIR="${BALLUP_REMOTE_DIR}/deploy"
SSH_OPTS=(-i "${BALLUP_SSH_KEY}" -o IdentitiesOnly=yes)

remote() {
  ssh "${SSH_OPTS[@]}" "${BALLUP_SERVER}" "$@"
}

remote_tty() {
  ssh -t "${SSH_OPTS[@]}" "${BALLUP_SERVER}" "$@"
}

# Image tag = short commit SHA; uncommitted changes are marked so the image is never mistaken for a commit.
image_tag() {
  local sha
  sha="$(git -C "${REPO_ROOT}" rev-parse --short HEAD)"
  if [[ -n "$(git -C "${REPO_ROOT}" status --porcelain -- backend)" ]]; then
    echo "${sha}-dirty"
  else
    echo "${sha}"
  fi
}
