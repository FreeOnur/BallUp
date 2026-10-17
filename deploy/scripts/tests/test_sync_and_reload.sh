#!/usr/bin/env bash
# Regression tests for deploy sync and stack reload.
#   bash deploy/scripts/tests/test_sync_and_reload.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PASS=0

assert() {
  local label="$1"
  shift
  if "$@"; then
    echo "ok: ${label}"
    PASS=$((PASS + 1))
  else
    echo "FAIL: ${label}" >&2
    exit 1
  fi
}

make_mocks() {
  local dir="$1"
  mkdir -p "${dir}"
  cat > "${dir}/ssh" <<'EOF'
#!/usr/bin/env bash
cmd=""
for arg in "$@"; do
  cmd="${arg}"
done
if [[ "${FAIL_REMOTE_TAR:-}" == "1" ]]; then
  export PATH="${FAIL_TAR_DIR:?}:${PATH}"
fi
bash -c "${cmd}"
EOF
  cat > "${dir}/docker" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "${DOCKER_LOG:?}"
if [[ "$*" == *" ps "* || "$*" == ps* ]]; then
  printf 'abc123\n'
  exit 0
fi
if [[ "$*" == *inspect* ]]; then
  printf 'healthy\n'
  exit 0
fi
exit 0
EOF
  chmod +x "${dir}/ssh" "${dir}/docker"
}

# config.sh appends /deploy to BALLUP_REMOTE_DIR. Live files live in that directory.
deploy_dir() {
  printf '%s/deploy' "$1"
}

test_failed_sync_keeps_live_caddyfile() {
  local tmp mocks base remote fail_tar
  tmp="$(mktemp -d)"
  mocks="${tmp}/bin"
  base="${tmp}/opt/ballup"
  remote="$(deploy_dir "${base}")"
  fail_tar="${tmp}/fail-tar"
  make_mocks "${mocks}"
  mkdir -p "${fail_tar}" "${remote}/caddy"
  cat > "${fail_tar}/tar" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
  chmod +x "${fail_tar}/tar"
  printf 'LIVE-CADDY\n' > "${remote}/caddy/Caddyfile"

  set +e
  FAIL_REMOTE_TAR=1 FAIL_TAR_DIR="${fail_tar}" \
    BALLUP_REMOTE_DIR="${base}" BALLUP_SERVER="deploy@example.test" \
    PATH="${mocks}:${PATH}" \
    bash "${REPO_ROOT}/deploy/scripts/deploy/sync.sh" >"${tmp}/out" 2>"${tmp}/err"
  local code=$?
  set -e

  assert "failed sync exits non-zero" test "${code}" -ne 0
  assert "failed sync keeps the live Caddyfile" grep -qx 'LIVE-CADDY' "${remote}/caddy/Caddyfile"
  rm -rf "${tmp}"
}

test_sync_publishes_files_and_keeps_env() {
  local tmp mocks base remote
  tmp="$(mktemp -d)"
  mocks="${tmp}/bin"
  base="${tmp}/opt/ballup"
  remote="$(deploy_dir "${base}")"
  make_mocks "${mocks}"
  mkdir -p "${remote}/compose" "${remote}/caddy"
  printf 'LIVE-CADDY\n' > "${remote}/caddy/Caddyfile"
  printf 'GRAFANA_ADMIN_PASSWORD=keep-me\n' > "${remote}/compose/.env"

  BALLUP_REMOTE_DIR="${base}" BALLUP_SERVER="deploy@example.test" \
    PATH="${mocks}:${PATH}" \
    bash "${REPO_ROOT}/deploy/scripts/deploy/sync.sh" >"${tmp}/out"

  assert "sync replaces the Caddyfile" grep -q 'uptime-kuma:3001' "${remote}/caddy/Caddyfile"
  assert "sync does not leave the previous Caddyfile" test ! -e "${remote}/caddy.prev"
  assert "sync keeps the server .env" grep -qx 'GRAFANA_ADMIN_PASSWORD=keep-me' "${remote}/compose/.env"
  assert "sync installs compose.yml" test -f "${remote}/compose/compose.yml"
  assert "sync installs pull.sh and marks it executable" test -x "${remote}/scripts/server/pull.sh"
  assert "sync removes the staging dir" test ! -e "${remote}/.sync-staging"
  rm -rf "${tmp}"
}

run_pull() {
  local mode="$1"
  local tmp mocks root log
  tmp="$(mktemp -d)"
  mocks="${tmp}/bin"
  root="${tmp}/tree"
  log="${tmp}/docker.log"
  make_mocks "${mocks}"
  mkdir -p "${root}/deploy/scripts/server" "${root}/deploy/compose"
  cp "${REPO_ROOT}/deploy/scripts/server/pull.sh" "${root}/deploy/scripts/server/pull.sh"
  chmod +x "${root}/deploy/scripts/server/pull.sh"
  printf 'BALLUP_API_IMAGE=example\n' > "${root}/deploy/compose/.env"
  : > "${log}"

  DOCKER_LOG="${log}" PATH="${mocks}:${PATH}" \
    bash "${root}/deploy/scripts/server/pull.sh" "${mode}" "example/api:abc" >"${tmp}/out"

  PULL_LOG="${log}"
  PULL_TMP="${tmp}"
}

test_full_deploy_recreates_config_services() {
  run_pull all
  assert "full deploy recreates caddy" grep -q 'up -d --force-recreate --no-deps caddy prometheus tempo grafana' "${PULL_LOG}"
  assert "full deploy still starts the whole stack" grep -q 'up -d --remove-orphans' "${PULL_LOG}"
  rm -rf "${PULL_TMP}"
}

test_api_deploy_does_not_recreate_caddy() {
  run_pull api
  assert "api deploy does not force-recreate caddy" bash -c '! grep -q force-recreate "$1"' bash "${PULL_LOG}"
  assert "api deploy restarts the api service" grep -q 'up -d api' "${PULL_LOG}"
  rm -rf "${PULL_TMP}"
}

test_failed_sync_keeps_live_caddyfile
test_sync_publishes_files_and_keeps_env
test_full_deploy_recreates_config_services
test_api_deploy_does_not_recreate_caddy

echo "${PASS} assertions passed"
