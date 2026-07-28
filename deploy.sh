#!/bin/bash

set -e

log() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1"
    exit 1
}

SERVER="subi@192.168.1.6"
TARGET="/opt/subicloud"

if [ $# -eq 0 ]; then
    error "Usage: ./deploy.sh <app>"
    exit 1
fi

APP="$1"

log "=================================="
log " SubiCloud Deployment"
log "=================================="
echo ""
log "Deploying application: $APP"
echo ""
log "Syncing files..."

rsync -av --delete \
    --exclude ".git" \
    ./ "$SERVER:$TARGET"

echo ""
log "Running deployment..."

ssh "$SERVER" "bash $TARGET/scripts/deploy_app.sh $APP"

echo ""
log "Deployment completed successfully."
