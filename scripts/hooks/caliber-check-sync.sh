#!/bin/sh
# Shared Caliber setup nudge when pre-commit hook is missing (Claude Code Stop hook).
if [ "$CALIBER_SUBPROCESS" = "1" ] || [ -n "$CALIBER_SPAWNED" ]; then
  exit 0
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

if grep -q "caliber" .git/hooks/pre-commit 2>/dev/null; then
  exit 0
fi

FLAG="/tmp/caliber-nudge-$(echo "$PWD" | (shasum 2>/dev/null || sha1sum 2>/dev/null || md5sum 2>/dev/null || cksum) | cut -c1-8)"
find /tmp -maxdepth 1 -name "caliber-nudge-*" -mmin +120 -delete 2>/dev/null

if [ -f "$FLAG" ]; then
  exit 0
fi

touch "$FLAG"
printf '{"decision":"block","reason":"Caliber agent config sync is not set up on this machine. Tell the user: This project uses Caliber to keep agent configs in sync — it is not set up yet. Want me to run /setup-caliber? (~30 seconds)"}'
