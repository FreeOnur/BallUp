#!/usr/bin/env bash
# Copies the server-side files (compose, Caddy, observability, server scripts) to the server.
# The server has no git checkout; deploy/compose/.env on the server is never touched.
#   sync.sh
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

echo "syncing deploy files to ${BALLUP_SERVER}:${REMOTE_DEPLOY_DIR}..."

# Extract into a staging directory and publish with rename only after tar
# succeeds. Removing the live Caddyfile before the archive has arrived deletes
# the proxy config if SSH drops, and the next Caddy start then takes the API down.
remote_cmd=$(cat <<EOF
set -euo pipefail
mkdir -p '${REMOTE_DEPLOY_DIR}/compose'
cd '${REMOTE_DEPLOY_DIR}'
rm -rf .sync-staging
mkdir -p .sync-staging
tar -xf - -C .sync-staging
publish() {
  src="\$1"
  dest="\$2"
  mkdir -p "\$(dirname "\$dest")"
  rm -rf "\${dest}.new"
  mv "\$src" "\${dest}.new"
  if [ -e "\$dest" ]; then
    rm -rf "\${dest}.prev"
    mv "\$dest" "\${dest}.prev"
  fi
  mv "\${dest}.new" "\$dest"
  rm -rf "\${dest}.prev"
}
install_file() {
  src="\$1"
  dest="\$2"
  cp "\$src" "\${dest}.new"
  mv -f "\${dest}.new" "\$dest"
}
publish .sync-staging/caddy caddy
publish .sync-staging/observability observability
publish .sync-staging/scripts/server scripts/server
install_file .sync-staging/compose/compose.yml compose/compose.yml
install_file .sync-staging/compose/compose.observability.yml compose/compose.observability.yml
install_file .sync-staging/compose/.env.example compose/.env.example
rm -rf .sync-staging
find caddy observability scripts/server -name '*.sh' -exec chmod +x {} +
EOF
)

tar -C "${REPO_ROOT}/deploy" -cf - \
  compose/compose.yml \
  compose/compose.observability.yml \
  compose/.env.example \
  caddy \
  observability \
  scripts/server \
  | remote "${remote_cmd}"
echo "sync done"
