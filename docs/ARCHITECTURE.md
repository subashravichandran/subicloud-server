# Architecture

## Runtime

Ubuntu Server

Docker Engine

## Platform

/opt/subicloud

## Data

/srv

## Development

Git Repository

VS Code

SSH

## Philosophy

- Configuration is stored in Git.
- Customer data is stored in /srv.
- Application runtime lives in /opt/subicloud.
- Raspberry Pi compatible
- SSD stores OS and application configuration
- HDD stores customer data
- Git is the single source of truth
- Never modify running containers manually
