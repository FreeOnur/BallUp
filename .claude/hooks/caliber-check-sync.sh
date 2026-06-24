#!/bin/sh
exec sh "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/../../scripts/hooks/caliber-check-sync.sh"
