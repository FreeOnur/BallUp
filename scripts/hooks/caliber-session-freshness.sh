#!/bin/sh
# Shared Caliber session freshness check (Cursor + Claude Code).
# Don't run inside a caliber-spawned headless session.
if [ "$CALIBER_SUBPROCESS" = "1" ] || [ -n "$CALIBER_SPAWNED" ]; then
  exit 0
fi

STATE_FILE=".caliber/.caliber-state.json"
[ ! -f "$STATE_FILE" ] && exit 0

LAST_SHA=$(grep -o '"lastRefreshSha":"[^"]*"' "$STATE_FILE" 2>/dev/null | cut -d'"' -f4)
[ -z "$LAST_SHA" ] && exit 0

CURRENT_SHA=$(git rev-parse HEAD 2>/dev/null)
[ "$LAST_SHA" = "$CURRENT_SHA" ] && exit 0

COMMITS_BEHIND=$(git rev-list --count "$LAST_SHA".."$CURRENT_SHA" 2>/dev/null || echo 0)

if [ "$COMMITS_BEHIND" -gt 15 ]; then
  if command -v caliber >/dev/null 2>&1; then
    CALIBER_CMD="caliber refresh"
  else
    CALIBER_CMD="npx @rely-ai/caliber refresh"
  fi
  printf '{"systemMessage":"Caliber: agent configs are %s commits behind. Run `%s` to sync."}' "$COMMITS_BEHIND" "$CALIBER_CMD"
fi
