#!/bin/bash

set -euo pipefail

################################################################################
# Logging
################################################################################

log() {
    echo "[INFO] $1"
}

success() {
    echo "[SUCCESS] $1"
}

error() {
    echo "[ERROR] $1" >&2
    exit 1
}

################################################################################
# Validate arguments
################################################################################

APP="${1:-}"

if [ -z "$APP" ]; then
    error "Usage: deploy_app.sh <app>"
fi

################################################################################
# Load platform configuration
################################################################################

CONFIG_FILE="/opt/subicloud/configs/platform.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    error "Platform configuration not found: $CONFIG_FILE"
fi

source "$CONFIG_FILE"

################################################################################
# Application paths
################################################################################

APP_DIR="$PLATFORM_DIR/apps/$APP"
APP_DATA_DIR="$DATA_DIR/$APP"

################################################################################
# Validate application
################################################################################

if [ ! -d "$APP_DIR" ]; then
    error "Application '$APP' not found.

Available applications:
$(find "$PLATFORM_DIR/apps" -mindepth 1 -maxdepth 1 -type d -printf ' - %f\n')"
fi

################################################################################
# Load application metadata
################################################################################

APP_CONFIG="$APP_DIR/app.env"

if [ ! -f "$APP_CONFIG" ]; then
    error "Missing app.env for '$APP'."
fi

source "$APP_CONFIG"

################################################################################
# Deploy
################################################################################

log "Deploying $DISPLAY_NAME..."

mkdir -p "$APP_DATA_DIR"

if [ ! -f "$APP_DATA_DIR/.env" ]; then
    log "Creating .env from template..."
    cp "$APP_DIR/.env.example" "$APP_DATA_DIR/.env"
fi

cd "$APP_DIR"

log "Starting Docker containers..."

docker compose up -d

################################################################################
# Verify deployment
################################################################################

log "Verifying deployment..."

CONTAINER_STATUS=$(docker inspect \
    -f '{{.State.Status}}' \
    "$CONTAINER_NAME" 2>/dev/null || echo "missing")

if [ "$CONTAINER_STATUS" != "running" ]; then
    echo
    echo "Last 20 log lines:"
    docker logs "$CONTAINER_NAME" --tail 20 || true
    error "$DISPLAY_NAME failed to start."
fi

success "$DISPLAY_NAME is running."
success "$DISPLAY_NAME deployed successfully."
