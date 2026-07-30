# Technical TODO

## High Priority

### Make network configurable

Current state:

The Docker network is named `subicloud`.

Future goal:

Support multiple independent deployments (stacks), each with its own network.

Example:

```
Home
NETWORK_NAME=subicloud

John
NETWORK_NAME=johncloud

Chris
NETWORK_NAME=chriscloud
```

Applications should never hardcode the network name.

Instead they should use:

```yaml
networks:
  default:
    name: ${NETWORK_NAME}
    external: true
```

The deployment engine should export `NETWORK_NAME` before invoking Docker Compose.

Status:

Deferred until multi-stack support is implemented.

## Optimize deployment synchronization

Current behavior:

`deploy.sh` synchronizes the entire platform before deploying a single application.

Future improvement:

Synchronize:

- configs/
- scripts/
- templates/
- documentation (optional)
- only the selected application's directory

Example:

./deploy.sh homarr

↓

apps/homarr

instead of

↓

apps/*


## Cloudflare Tunnel

Status:

Core integration completed.

### Remaining Tasks

- Automatically generate Cloudflared ingress from application metadata.
- Automatically create DNS records during deployment.
- Support multiple public hostnames.
- Reload Cloudflared automatically after configuration changes.
- Validate public routes after deployment.
- Add automatic HTTPS verification.
- Support wildcard hostnames.

## Deployment Engine

### Cloudflared Automation

Future goal:

Deploying an application with public exposure should automatically:

1. Read hostname metadata from `app.env`
2. Update `config.template.yml`
3. Generate `/srv/data/cloudflared/config.yml`
4. Reload Cloudflared
5. Create Cloudflare DNS record (if required)
6. Verify public accessibility

Example:

```
./deploy.sh nextcloud
```

↓

Nextcloud deployed

↓

Cloudflare updated

↓

HTTPS verified

↓

Deployment complete
```

## High Priority

### Decouple Applications from Domain Structure

**Goal**

Applications should not assume whether a deployment uses a subdomain of `subicloud.com` or a completely custom domain.

**Current Idea**

```bash
PLATFORM_NAME=john
BASE_DOMAIN=subicloud.com

PUBLIC_HOSTNAMES=dash.${PLATFORM_NAME}.${BASE_DOMAIN}
```

This ties applications to a specific domain structure.

---

**Proposed Design**

Store the platform's root domain in `platform.conf`:

```bash
PLATFORM_DOMAIN=john.subicloud.com
```

Applications use:

```bash
PUBLIC_HOSTNAMES=dash.${PLATFORM_DOMAIN}
```

Examples:

| PLATFORM_DOMAIN | Generated Hostname |
|-----------------|--------------------|
| home.subicloud.com | dash.home.subicloud.com |
| john.subicloud.com | dash.john.subicloud.com |
| johncloud.com | dash.johncloud.com |
| cloud.acme.com | dash.cloud.acme.com |

---

**Benefits**

- Applications remain domain-agnostic.
- Supports both SubiCloud-managed subdomains and customer-owned domains.
- Future-proof for enterprise deployments.
- Customer onboarding requires updating only `platform.conf`.