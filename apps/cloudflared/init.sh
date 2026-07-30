#!/bin/bash

set -e

echo "[INFO] Preparing Cloudflared..."

mkdir -p "$APP_DATA_DIR"

if [ ! -f "$APP_DATA_DIR/credentials.json" ]; then
    echo "[ERROR] credentials.json not found."
    echo "Copy your tunnel credentials to:"
    echo "  $APP_DATA_DIR/credentials.json"
    exit 1
fi

echo "[INFO] Cloudflared is ready."