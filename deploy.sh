#!/bin/bash

set -e

SERVER="subi@192.168.1.6"
TARGET="/opt/subicloud"

echo "Deploying SubiCloud..."

rsync -av --delete \
    --exclude ".git" \
    ./ "$SERVER:$TARGET"

echo "Deployment Done!"
