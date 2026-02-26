# Architecture Snapshot (Redacted)

Last updated: 2026-02-24 UTC
Host role: primary OpenClaw + automation + observability + web ingress

## 1) Host Baseline
- Provider/VM: Hetzner vServer (KVM)
- OS: Ubuntu 24.04.3 LTS
- Kernel: 6.8.0-100-generic
- Node: 22.21.0

## 2) Core Control Plane
- OpenClaw Gateway: active via systemd (loopback bind)
  - UI/API endpoint (local): `127.0.0.1:18791`
  - Side ports (local): `127.0.0.1:18793`, `127.0.0.1:18794`
- Telegram channel integration: enabled/healthy
- Tailscale: installed (not enabled in OpenClaw status output)

## 3) Public Edge / Remote Access
- Public listeners:
  - `:80` (nginx)
  - `:443` (nginx)
  - `:22` (ssh)
- App/public service exposure observed:
  - `:3002` mapped from Docker (`firecrawl-api`)

## 4) Automation & Services
- user-level systemd active:
  - `openclaw-gateway.service` (running)
- system-level systemd active:
  - `n8n.service` (running)
  - `docker.service` (running)
- `pm2-agentadmin.service` is installed but currently inactive

## 5) Docker Stack (observed)
### Observability
- Prometheus (`127.0.0.1:9090`)
- Grafana (`100.101.39.72:3000`)
- Node Exporter (`127.0.0.1:9100`)
- Blackbox Exporter (`127.0.0.1:9115`)
- cAdvisor (`127.0.0.1:8080`)

### Firecrawl stack
- API: `firecrawl-api-1` (`0.0.0.0:3002->3002`)
- Workers: `firecrawl-worker-1`, `firecrawl-worker-2`, `firecrawl-nuq-worker-1`
- DB: `firecrawl-nuq-postgres-1` (internal)
- Redis: `firecrawl-redis-1` (internal)
- Playwright service: `firecrawl-playwright-service-1`

## 6) Risk/Gap Notes (Immediate)
1. OpenClaw security warning: trusted reverse proxy headers not configured.
2. Public `:3002` exposure should be intentional and documented (auth/rate-limit/WAF).
3. PM2 is inactive while systemd is active; process ownership standard should be fixed (single source of truth).

## 7) Config Paths & Runtime Sources (Redacted)
- OpenClaw user unit: `/root/.config/systemd/user/openclaw-gateway.service`
- n8n systemd unit: `/etc/systemd/system/n8n.service`
- Docker systemd unit: `/usr/lib/systemd/system/docker.service`
- PM2 systemd unit: `/etc/systemd/system/pm2-agentadmin.service`
- OpenClaw data root (symlink): `/home/agentadmin/.openclaw -> /mnt/HC_Volume_103972109/openclaw_data`
- n8n data root (symlink): `/home/agentadmin/.n8n -> /mnt/HC_Volume_103972109/n8n_data`

## 8) Weekly Verification Checklist
- Run `openclaw status --deep`
- Verify user/systemd units are healthy (`systemctl --user status openclaw-gateway`, `systemctl status n8n docker`)
- Verify public ports (`ss -ltnup`) against intended exposure list
- Validate Docker stack health (`docker ps`)
- Validate unit files did not gain plaintext credentials unexpectedly
- Update this file if topology/ports/services changed
