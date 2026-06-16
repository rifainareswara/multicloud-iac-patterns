# Role: `compose_stack`

Idempotently deploys a self-hosted Docker Compose stack from a config-as-code
git repo, injecting managed secrets that are kept out of version control.

## What it does

1. Ensures `git` is installed.
2. Clones/updates the compose repo (config-as-code) on the target host.
3. Copies a managed `.env` (mode `0600`) for the stack, if one exists locally.
4. Copies a managed `files/` tree (secrets/config that don't fit in `.env`,
   mode `0644` so in-container processes can read them).
5. Ensures the shared docker network exists.
6. `docker compose pull` + `up -d --remove-orphans`, then reports status.

## Why secrets are split out

The compose repo is config-as-code and may be shared/public. Secrets (`.env`,
bearer tokens) live **only** on the control node under `compose_env_dir` and are
pushed at deploy time — they never enter the compose repo's git history.

## Usage

```yaml
- hosts: monitoring
  roles:
    - role: compose_stack
      vars:
        stack_service: grafana-prometheus
```

See [`defaults/main.yml`](./defaults/main.yml) for all variables.
