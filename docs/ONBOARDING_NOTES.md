# Cloudflare Tunnel Setup Guide (SubiCloud)

## Overview

This document describes how to create and configure a Cloudflare Tunnel for a new SubiCloud installation.

This is currently a one-time manual setup per customer/server.

---

# Prerequisites

- Ubuntu Server
- Docker & Docker Compose installed
- Cloudflare account
- Domain added to Cloudflare
- `cloudflared` CLI installed

---

# 1. Login to Cloudflare

```bash
cloudflared tunnel login
```

This opens a browser.

Authorize Cloudflare to manage your domain.

A certificate is downloaded to:

```
~/.cloudflared/cert.pem
```

---

# 2. Create a Tunnel

Choose a descriptive name.

Example:

```bash
cloudflared tunnel create subicloud
```

Example output:

```
Tunnel credentials written to:

/home/subi/.cloudflared/<tunnel-id>.json

Created tunnel:

822ccb9e-5678-4294-b2c7-535db6757db0
```

Save the Tunnel ID.

Example:

```
822ccb9e-5678-4294-b2c7-535db6757db0
```

---

# 3. Copy Tunnel Credentials

Create runtime directory:

```bash
sudo mkdir -p /srv/data/cloudflared
```

Copy credentials:

```bash
sudo cp ~/.cloudflared/<tunnel-id>.json \
    /srv/data/cloudflared/credentials.json
```

Set permissions:

```bash
sudo chmod 644 /srv/data/cloudflared/credentials.json
```

---

# 4. Configure platform.conf

Example:

```bash
PLATFORM_DOMAIN=home.subicloud.com
```

(or)

```bash
PLATFORM_DOMAIN=john.subicloud.com
```

(or)

```bash
PLATFORM_DOMAIN=johncloud.com
```

---

# 5. Configure Cloudflared app

Update:

```
apps/cloudflared/app.env
```

Set:

```bash
TUNNEL_ID=<your tunnel id>
```

Example:

```bash
TUNNEL_ID=822ccb9e-5678-4294-b2c7-535db6757db0
```

---

# 6. Deploy Cloudflared

```bash
./deploy.sh cloudflared
```

Deployment creates:

```
/srv/data/cloudflared/config.yml
```

using

```
apps/cloudflared/config.template.yml
```

---

# 7. Verify Container

```bash
docker ps
```

Should show:

```
cloudflared
```

View logs:

```bash
docker logs -f cloudflared
```

Expected:

```
Registered tunnel connection
```

No authentication errors should appear.

---

# 8. Create DNS Routes

Create a DNS route for each hostname.

Example:

```bash
cloudflared tunnel route dns subicloud dash.home.subicloud.com
```

or

```bash
cloudflared tunnel route dns subicloud dash.john.subicloud.com
```

This creates the required Cloudflare CNAME record pointing to the tunnel.

> **Future Enhancement:** Automate DNS record creation during deployment using the Cloudflare API.

---

# 9. Configure Applications

Applications expose themselves through `app.env`.

Example:

```bash
PUBLIC_ENABLED=true

PUBLIC_HOSTNAMES=dash.${PLATFORM_DOMAIN}

PUBLIC_PROTOCOL=http

PUBLIC_PORT=7575
```

The deployment engine automatically discovers these values.

---

# 10. Deploy Applications

Example:

```bash
./deploy.sh homarr
```

Deployment automatically:

- Deploys Homarr
- Runs post-deployment hooks
- Regenerates Cloudflared configuration
- Restarts Cloudflared only if configuration changed

No manual edits to `config.yml` are required.

---

# Generated Cloudflared Configuration

Example:

```yaml
tunnel: 822ccb9e-5678-4294-b2c7-535db6757db0

credentials-file: /etc/cloudflared/credentials.json

ingress:
  - hostname: dash.home.subicloud.com
    service: http://homarr:7575

  - service: http_status:404
```

This file is fully generated.

Do **not** edit it manually.

---

# Current Automation

Automated:

- Cloudflared deployment
- Configuration generation
- Ingress generation
- Application discovery
- Configuration comparison
- Restart only when configuration changes

Manual:

- Cloudflare login
- Tunnel creation
- Tunnel credential download
- DNS route creation

---

# File Locations

## Repository

```
apps/cloudflared/
├── app.env
├── compose.yml
├── config.template.yml
├── init.sh
└── README.md
```

---

## Runtime

```
/srv/data/cloudflared/
├── credentials.json
└── config.yml
```

---

## Scripts

```
scripts/
├── update_cloudflared_config.sh
├── post_deploy.sh
└── hooks/
    └── post_deploy/
        └── 10-cloudflared.sh
```

---

# Deployment Flow

```
deploy.sh
        │
        ▼
deploy_app.sh
        │
        ▼
Deploy application
        │
        ▼
post_deploy.sh
        │
        ▼
10-cloudflared.sh
        │
        ▼
update_cloudflared_config.sh
        │
        ├── Read all app.env files
        ├── Generate temporary config
        ├── Compare with current config
        ├── Replace if changed
        ├── Restart Cloudflared if changed
        └── Finish
```

---

# Future Improvements

- Bootstrap script (`bootstrap.sh`) to automate server initialization
- Automatic Docker installation
- Automatic Docker network creation
- Automatic Cloudflared deployment
- Automatic Cloudflare DNS management using the Cloudflare API
- Variable expansion from `platform.conf`
- Customer-independent application metadata
- One-command customer onboarding