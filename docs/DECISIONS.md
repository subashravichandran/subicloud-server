# Decision Log

## 2026-07-28

### Decision

Use Git as the single source of truth.

### Reason

Configuration should never exist only on the server.

---

### Decision

Runtime configuration lives in /opt/subicloud.

### Reason

Keeps the platform isolated from the operating system.
