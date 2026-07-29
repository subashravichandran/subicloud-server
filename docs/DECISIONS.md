# SubiCloud Decision Log

This document records important architectural decisions and the reasoning behind them.

---

# 2026-07-28

## Decision

Use Git as the single source of truth.

### Reason

All platform code should be reproducible from version control.

A new server should be recoverable by cloning the repository and running the deployment scripts.

No manual server-side changes should be required.

---

## Decision

Separate platform code from runtime data.

### Platform

```
/opt/subicloud
```

### Runtime

```
/srv/data
```

### Reason

Platform code can always be redeployed.

Runtime data must survive:

- deployments
- updates
- operating system reinstalls

---

## Decision

Centralize platform configuration.

### File

```
configs/platform.conf
```

### Reason

Deployment scripts should never hardcode platform paths.

Changing a platform path should require updating only one file.

---

## Decision

Each application is self-contained.

### Standard Structure

```
apps/
└── app-name/
    ├── app.env
    ├── compose.yml
    ├── .env.example
    └── README.md
```

### Reason

Every application follows identical conventions.

Adding a new application should require no changes to the deployment engine.

---

## Decision

Store runtime configuration under `/srv/data`.

### Example

```
/srv/data/homarr/.env
```

### Reason

Runtime configuration belongs with runtime data.

It should not be overwritten during deployments or stored in Git.

---

## Decision

Introduce `app.env` for application metadata.

### Example

```bash
APP_NAME=homarr
DISPLAY_NAME=Homarr
CONTAINER_NAME=homarr
```

### Reason

The deployment engine should not assume implementation details such as container names.

Applications describe themselves through metadata instead of requiring platform-specific logic.

---

## Decision

Use a generic deployment engine.

### Command

```bash
./deploy.sh <app>
```

### Reason

The deployment process should be identical for every application.

Deploying a new application should not require modifying deployment scripts.

---

## Decision

Deploy using Docker Compose.

### Reason

Docker Compose provides a simple, declarative way to define and manage self-hosted applications while keeping each application isolated.

---

## Decision

Runtime `.env` files are generated only once.

### Reason

During the first deployment:

```
.env.example
```

is copied to:

```
/srv/data/<app>/.env
```

Subsequent deployments never overwrite the runtime configuration.

This preserves user modifications.

---

## Decision

Validate deployments after startup.

### Reason

Starting containers does not guarantee a successful deployment.

The deployment engine verifies that the container is running and displays recent logs if startup fails.

---

## Decision

The deployment engine contains no application-specific logic.

### Reason

All application-specific information belongs inside the application's own directory.

The deployment engine should work for any application that follows the platform conventions.

# 29-07-2026

## Optional Application Initialization

### Decision

Applications may provide an optional `init.sh` script.

The deployment engine automatically executes this script during deployment after
creating the application's runtime directory.

### Rationale

Different applications have different initialization requirements.

Examples include:

- Creating additional runtime directories
- Copying default configuration files
- Performing first-time setup

Keeping this logic inside each application prevents the deployment engine from
accumulating application-specific behavior.

### Consequences

Advantages:

- Generic deployment engine
- Self-contained applications
- Easy to add new applications
- No hardcoded application logic

Trade-off:

- Applications requiring initialization must maintain an `init.sh` script.

---

## Decision

Store application configuration in Git.

### Reason

Application configuration is source code.

Configuration should be version controlled, reviewed and recoverable from Git.

Runtime state remains under /srv/data.

---

## Decision

Cloudflare Tunnel is the recommended method for exposing SubiCloud services.

### Reason

Many residential Internet providers use CGNAT, making inbound connections impossible even with correct router configuration.

Cloudflare Tunnel provides:

- HTTPS
- No port forwarding
- No static IP
- Works behind CGNAT

Traditional public-IP deployments remain supported.

---

## Decision

Manage Cloudflare Tunnel locally instead of using Dashboard-managed token authentication.

### Reason

Locally managed tunnels provide:

- Infrastructure as Code
- Version-controlled tunnel configuration
- Scriptable DNS management
- Independence from Cloudflare dashboard UI changes

Only tunnel credentials remain outside Git.

---

## Decision

Cloudflared follows the standard SubiCloud application model.

### Structure

```
apps/cloudflared/
├── app.env
├── compose.yml
├── config.template.yml
├── init.sh
└── README.md
```

Runtime:

```
/srv/data/cloudflared/
├── config.yml
└── credentials.json
```

### Reason

Cloudflared should behave like every other SubiCloud application instead of requiring special deployment logic.

---

## Decision

Generate Cloudflared configuration during deployment.

### Reason

The repository stores configuration templates.

`init.sh` generates the runtime configuration before Docker starts.

Advantages:

- Version-controlled configuration
- Runtime-specific values injected during deployment
- No generated configuration stored in Git

---

## Decision

Cloudflare Tunnel credentials are runtime secrets.

### Reason

`credentials.json` uniquely identifies the tunnel and must never be committed to Git.

Only the server stores these credentials under:

```
/srv/data/cloudflared/credentials.json
```