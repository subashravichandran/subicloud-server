#!/bin/bash

set -e

log() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1"
    exit 1
}

APP="$1"

if [ -z "$APP" ]; then
    error "Usage: deploy_app.sh <app>"
    exit 1
fi

CONFIG_FILE="/opt/subicloud/configs/platform.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    error "Platform configuration not found."
    exit 1
fi

source "$CONFIG_FILE"

APP_DIR="$PLATFORM_DIR/apps/$APP"
APP_DATA_DIR="$DATA_DIR/$APP"

if [ ! -d "$APP_DIR" ]; then
    error "Application '$APP' not found.

Available applications:
$(find "$PLATFORM_DIR/apps" -mindepth 1 -maxdepth 1 -type d -printf ' - %f\n')"
    exit 1
fi

log "Deploying $APP..."

mkdir -p "$APP_DATA_DIR"

if [ ! -f "$APP_DATA_DIR/.env" ]; then
    log "Creating .env"
    cp "$APP_DIR/.env.example" "$APP_DATA_DIR/.env"
fi

cd "$APP_DIR"

docker compose up -d

log "$APP deployed successfully."
