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

set -a
source "$CONFIG_FILE"
set +a

################################################################################
# Application paths
################################################################################

APP_DIR="$PLATFORM_DIR/apps/$APP"
APP_DATA_DIR="$DATA_DIR/$APP"

export APP_DIR
export APP_DATA_DIR

################################################################################
# File write validation
################################################################################

if [ ! -w "$DATA_DIR" ]; then
    error "No write permission to $DATA_DIR"
    exit 1
fi

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

set -a
source "$APP_CONFIG"
set +a

################################################################################
# Deploy
################################################################################

log "Deploying $DISPLAY_NAME..."

################################################################################
# Initialize runtime data
################################################################################

mkdir -p "$APP_DATA_DIR"

if [ -f "$APP_DIR/.env.example" ] && [ ! -f "$APP_DATA_DIR/.env" ]; then
    log "Creating .env from template..."
    cp "$APP_DIR/.env.example" "$APP_DATA_DIR/.env"
fi

################################################################################
# Run application initialization (optional)
################################################################################

INIT_SCRIPT="$APP_DIR/init.sh"

if [ -f "$INIT_SCRIPT" ]; then
    log "Running application initialization..."
    source "$INIT_SCRIPT"
fi

cd "$APP_DIR"

log "Starting Docker containers..."

docker compose \
    --env-file "$APP_DATA_DIR/.env" \
    up -d --force-recreate
    
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

################################################################################
# Post-deployment hooks
################################################################################

POST_DEPLOY_SCRIPT="$PLATFORM_DIR/scripts/post_deploy.sh"

if [ -x "$POST_DEPLOY_SCRIPT" ]; then
    log "Running post-deployment hooks..."
    "$POST_DEPLOY_SCRIPT"
fi