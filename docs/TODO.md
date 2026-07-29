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
