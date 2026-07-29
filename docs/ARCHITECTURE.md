# SubiCloud Architecture

## Overview

SubiCloud is a Git-driven deployment platform for self-hosted applications.

The platform follows a simple principle:

- Platform code is immutable and stored in Git.
- Runtime data is persistent and survives deployments.
- Applications are self-contained.
- Deployment is performed through a single generic deployment engine.

---

# Directory Structure

```
/opt/subicloud
├── apps/
│   └── <app>/
│       ├── app.env
│       ├── compose.yml
│       ├── init.sh         # Optional
│       ├── .env.example    # Optional
│       └── README.md
│
├── configs/
│   └── platform.conf
│
├── scripts/
│   └── deploy_app.sh
│
├── templates/
│
└── deploy.sh
```

Persistent application data:

```
/srv/data
└── <app>/
    ├── .env
    └── ...
```

---

# Responsibilities

## Platform

Location:

```
/opt/subicloud
```

Contains:

- deployment scripts
- application definitions
- templates
- documentation
- platform configuration

Everything in this directory is version controlled.

It should always be possible to recreate it from Git.

---

## Runtime Data

Location:

```
/srv/data
```

Contains:

- application data
- databases
- uploads
- runtime configuration (for example, `.env`)

This directory is **never** overwritten during deployment.

---

# Application Layout

Each application is self-contained.

Example:

```
apps/
└── homarr/
    ├── app.env
    ├── compose.yml
    ├── init.sh          # Optional
    ├── .env.example     # Optional
    └── README.md
```

### app.env

Metadata consumed by the SubiCloud deployment engine.

Example:

```bash
APP_NAME=homarr
DISPLAY_NAME=Homarr
CONTAINER_NAME=homarr
```

### compose.yml

Defines how Docker runs the application.

### .env.example

Optional template used to create the runtime configuration on first deployment.

Runtime copy:

```
/srv/data/<app>/.env
```

### init.sh

Optional application initialization script.

Used to perform application-specific initialization such as:

- Creating additional runtime directories
- Copying default configuration files
- Performing first-time setup

### README.md

Application-specific documentation.

---

# Platform Configuration

```
configs/platform.conf
```

Example:

```bash
PLATFORM_DIR=/opt/subicloud
DATA_DIR=/srv/data
```

This file centralizes all platform paths.

Deployment scripts must source this file instead of hardcoding directories.

---

# Deployment Flow

Developer Machine

```
Git
    │
    ▼
deploy.sh
    │
    ▼
rsync
    │
    ▼
Ubuntu Server
    │
    ▼
deploy_app.sh
    │
    ▼
Docker Compose
```

Deployment steps:

1. Synchronize platform files.
2. Load platform configuration.
3. Load application metadata.
4. Create the application's runtime directory.
5. Initialize the runtime environment (`.env` if applicable).
6. Run `init.sh` (if present).
7. Start or update the application.
8. Verify the container is running.

Application lifecycle:

```
deploy_app.sh
    │
    ├── Create runtime directory
    ├── Initialize runtime environment
    ├── Run init.sh (optional)
    ├── docker compose up -d
    └── Verify deployment
```

---

# Application Initialization

Each application may optionally provide an `init.sh` script.

The deployment engine invokes this script during every deployment after creating
the application's runtime directory and initializing the runtime environment.

Purpose of `init.sh`:

- Create application-specific runtime directories
- Copy default configuration files
- Perform first-time application initialization
- Prepare runtime data required before the container starts

The deployment engine does **not** contain application-specific initialization
logic. Instead, each application is responsible for defining its own
initialization process.

`init.sh` should be idempotent so it can safely run on every deployment.

Example:

```
apps/
└── caddy/
    ├── app.env
    ├── compose.yml
    ├── init.sh
    ├── Caddyfile
    └── README.md
```

Runtime layout:

```
/srv/data/
└── caddy/
    ├── Caddyfile
    ├── data/
    └── config/
```

---

# Design Principles

- Git is the single source of truth.
- Platform code and runtime data are separated.
- Applications are independent.
- Deployment is generic.
- Runtime configuration is never committed to Git.
- Every application follows the same directory structure.
- The deployment engine contains no application-specific logic.
- Application-specific initialization belongs in `init.sh`.
