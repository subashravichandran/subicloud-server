# SubiCloud - Project State

Version: v0.2 Foundation
Status: Generic deployment engine completed. Reverse proxy implementation in progress.

---

# Vision

SubiCloud is a Git-driven self-hosting platform for deploying and managing applications on a home server.

Goals:

- Git is the single source of truth.
- Platform code is immutable.
- Runtime data survives deployments.
- Applications are self-contained.
- One deployment engine deploys every application.
- Adding a new application should not require changing deployment scripts.

---

# Infrastructure

## Development Machine

- Lenovo Laptop
- Ubuntu Desktop

Responsibilities:

- Develop applications
- Update platform
- Push to Git
- Deploy to server

---

## Runtime Server

- HP Laptop
- Ubuntu Server
- Docker Engine
- Docker Compose

Runs all applications.

---

# Directory Structure

Platform:

```
/opt/subicloud
├── apps/
├── configs/
├── docs/
├── scripts/
├── templates/
├── deploy.sh
└── README.md
```

Persistent data:

```
/srv/data
└── <app>/
```

Principle:

```
/opt/subicloud
```

contains code.

```
/srv/data
```

contains runtime data.

---

# Platform Configuration

Location:

```
configs/platform.conf
```

Contents:

```bash
PLATFORM_DIR=/opt/subicloud
DATA_DIR=/srv/data
```

Deployment scripts must source this file.

No hardcoded platform paths.

---

# Application Structure

Every application follows the same convention.

Example:

```
apps/
└── <app>/
    ├── app.env          # Required
    ├── compose.yml      # Required
    ├── init.sh          # Optional
    ├── .env.example     # Optional
    └── README.md
```

---

## app.env

Contains metadata used by the deployment engine.

Example:

```bash
APP_NAME=homarr
DISPLAY_NAME=Homarr
CONTAINER_NAME=homarr
```

Future versions may include:

```bash
VERSION=1
HEALTHCHECK_URL=http://localhost:7575
```

---

## compose.yml

Docker Compose configuration.

Uses:

```yaml
name: homarr
```

Runtime environment:

```yaml
env_file:
  - /srv/data/homarr/.env
```

---

## .env.example

Template copied during first deployment.

Runtime copy:

```
/srv/data/<app>/.env
```

Never committed back to Git.

---

## init.sh

Optional application initialization script.

Executed by the deployment engine during every deployment.

Typical responsibilities include:

- Creating application-specific runtime directories
- Copying default configuration files
- Performing first-time initialization

`init.sh` should be idempotent so it can safely run multiple times.

---

## README.md

Application documentation.

---

# Deployment Engine

Main command:

```bash
./deploy.sh homarr
```

Workflow:

```
Lenovo

↓

deploy.sh

↓

rsync

↓

Ubuntu Server

↓

deploy_app.sh

↓

Docker Compose
```

---

# deploy.sh Responsibilities

Runs on the development machine.

Responsibilities:

- Validate arguments
- Synchronize files using rsync
- Execute remote deployment

Nothing application-specific exists here.

---

# deploy_app.sh Responsibilities

Runs on the server.

Workflow:

1. Validate application argument.
2. Load platform configuration.
3. Determine application directory.
4. Verify application exists.
5. Load application metadata.
6. Create the application's runtime directory.
7. Create .env from .env.example (if present).
8. Execute init.sh (if present).
9. Run Docker Compose.
10. Verify the container started.
11. Show logs if deployment fails.

The deployment engine contains no application-specific logic.

---

# Runtime Initialization

Applications may optionally provide an `init.sh`.

The deployment engine executes this script during every deployment.

The deployment engine is responsible for:

- Creating `/srv/data/<app>`
- Initializing `.env` from `.env.example` (if present)

Each application's `init.sh` is responsible only for application-specific initialization such as:

- Creating additional runtime directories
- Copying default configuration files
- Preparing runtime data before the container starts

---

# Runtime Layout

Example:

```
/srv/data
└── homarr
    ├── .env
    ├── database
    └── uploads
```

This directory survives:

- deployments
- Git updates
- server upgrades

---

# Logging Convention

Deployment scripts use helper functions.

```bash
log()
success()
error()
```

Example output:

```
[INFO] Deploying Homarr...
[INFO] Starting containers...
[SUCCESS] Homarr is running.
```

---

# Error Handling

Deployment validates:

- platform.conf exists
- application directory exists
- app.env exists
- container starts successfully

If deployment fails:

- shows Docker logs
- exits immediately

---

# Current Applications

## Homarr

Directory:

```
apps/homarr
```

Status:

✅ Working

Contains:

- compose.yml
- app.env
- init.sh
- .env.example
- README.md

Runtime:

```
/srv/data/homarr
```
## Caddy

Directory:

```
apps/caddy
```

Status:

🚧 In Progress

Contains:

- compose.yml
- app.env
- init.sh
- config/
    - Caddyfile
- README.md

Planned runtime:

```
/srv/data/caddy
├── data/
└── config/
```

init.sh creates the runtime directories.

The Caddyfile is version controlled and mounted directly from the application directory.

---

## Cloudflared

Directory:

```
apps/cloudflared
```

Status:

✅ Working (Locally Managed Tunnel)

Contains:

- compose.yml
- app.env
- config.template.yml
- init.sh
- README.md

Runtime:

```
/srv/data/cloudflared/
├── config.yml
└── credentials.json
```

Purpose:

- Connect SubiCloud to Cloudflare Tunnel
- Generate runtime configuration during deployment
- Route public hostnames to internal Docker services

# Design Principles

- Git is the source of truth.
- Runtime data is never stored in Git.
- Applications are independent.
- Platform code is reusable.
- One deployment engine serves every application.
- Configuration is centralized.
- Every application follows identical structure.
- Platform scripts contain zero application-specific code.

---

# Completed Milestones

✅ Ubuntu Server installed

✅ Docker installed

✅ Git repository created

✅ Standard directory structure

✅ Platform configuration

✅ Generic deployment engine

✅ Runtime data separation

✅ Automatic .env creation

✅ Optional application initialization (init.sh)

✅ Shared Docker network

✅ Logging helpers

✅ Application metadata (app.env)

✅ Deployment verification

✅ Cloudflare Tunnel authentication

✅ Named tunnel created

✅ Local tunnel management

✅ Runtime configuration generation

✅ Cloudflare DNS routing

✅ Cloudflared application integrated into deployment engine

---

# Next Milestones

## Platform

- SSH key authentication
- Health check URLs
- Docker image update command
- Rollback support
- Backup framework
- Restore framework

---

## Reverse Proxy

- Deploy Caddy
- Configure reverse proxy
- Local domain routing
- Cloudflare Tunnel (locally managed)
- Public service routing
- Automatic HTTPS

## Applications

- FileBrowser
- Nextcloud
- Uptime Kuma

---

## Deferred Architecture Improvements

- Configurable Docker network (`NETWORK_NAME`)
- Multi-stack deployments
- Stack-level configuration
- Unified `subicloud` CLI

---

## Future Features

- One-command platform bootstrap

```
./install.sh
```

- Application install

```
./deploy.sh nextcloud
```

- Application update

```
./update.sh homarr
```

- Application removal

```
./remove.sh homarr
```

- Backup

```
./backup.sh homarr
```

- Restore

```
./restore.sh homarr backup-2026-07-28.tar.gz
```

---

# Current Version

SubiCloud Platform

Version:

```
v0.1 Foundation
```

# Current focus:

Complete service routing through Caddy and expand Cloudflare Tunnel ingress generation while keeping the deployment engine generic and application-agnostic.