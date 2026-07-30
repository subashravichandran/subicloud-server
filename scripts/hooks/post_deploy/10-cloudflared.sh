#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../../configs/platform.conf"

"$PLATFORM_DIR/scripts/rebuild_cloudflared_config.sh"