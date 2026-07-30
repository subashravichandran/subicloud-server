#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../configs/platform.conf"

HOOK_DIR="$SCRIPT_DIR/hooks/post_deploy"

if [ ! -d "$HOOK_DIR" ]; then
    exit 0
fi

for HOOK in "$HOOK_DIR"/*.sh; do

    [ -f "$HOOK" ] || continue

    echo "[INFO] Running $(basename "$HOOK")..."

    "$HOOK"

done