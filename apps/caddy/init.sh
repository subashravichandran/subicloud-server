#!/bin/bash

mkdir -p "$APP_DATA_DIR"
mkdir -p "$APP_DATA_DIR/data"
mkdir -p "$APP_DATA_DIR/config"

if [ ! -f "$APP_DATA_DIR/Caddyfile" ]; then
    cp "$APP_DIR/Caddyfile" "$APP_DATA_DIR/Caddyfile"
fi
