#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_DIR="$(dirname "$SCRIPT_DIR")"

source "$PLATFORM_DIR/configs/platform.conf"

CLOUDFLARED_APP_DIR="$PLATFORM_DIR/apps/cloudflared"
TEMPLATE_FILE="$CLOUDFLARED_APP_DIR/config.template.yml"
CONFIG_DIR="$DATA_DIR/cloudflared"
OUTPUT_FILE="$CONFIG_DIR/config.yml"
TEMP_FILE="$(mktemp)"

source "$CLOUDFLARED_APP_DIR/app.env"

mkdir -p "$DATA_DIR/cloudflared"

echo "[INFO] Updating Cloudflared configuration..."

# Generate header
sed \
    -e "s|{{TUNNEL_ID}}|$TUNNEL_ID|g" \
    "$TEMPLATE_FILE" \
    > "$TEMP_FILE"

# Generate ingress rules
for APP_DIR in "$PLATFORM_DIR/apps"/*; do

    [ -d "$APP_DIR" ] || continue

    APP_ENV="$APP_DIR/app.env"

    [ -f "$APP_ENV" ] || continue

    unset APP_NAME
    unset DISPLAY_NAME
    unset CONTAINER_NAME
    unset PUBLIC_ENABLED
    unset PUBLIC_HOSTNAMES
    unset PUBLIC_PROTOCOL
    unset PUBLIC_PORT

    source "$APP_ENV"

    if [ "$PUBLIC_ENABLED" != "true" ]; then
        continue
    fi

    IFS=',' read -ra HOSTNAMES <<< "$PUBLIC_HOSTNAMES"

    for HOSTNAME in "${HOSTNAMES[@]}"; do

cat >> "$TEMP_FILE" <<EOF
  - hostname: $HOSTNAME
    service: ${PUBLIC_PROTOCOL}://${CONTAINER_NAME}:${PUBLIC_PORT}

EOF

    done

done

cat >> "$TEMP_FILE" <<EOF

  - service: http_status:404
EOF

if [ ! -f "$OUTPUT_FILE" ] || ! cmp -s "$TEMP_FILE" "$OUTPUT_FILE"; then

    mv "$TEMP_FILE" "$OUTPUT_FILE"

    echo "[INFO] Cloudflared configuration updated."

    docker restart cloudflared >/dev/null

    echo "[INFO] Cloudflared restarted."

else

    rm "$TEMP_FILE"

    echo "[INFO] Cloudflared configuration unchanged."

fi

echo "[SUCCESS] Cloudflared configuration complete."