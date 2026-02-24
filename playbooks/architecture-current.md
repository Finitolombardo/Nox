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
- systemd active:
  - `openclaw-gateway` (running)
  - `n8n` (running)
  - `docker` (running)
- PM2 currently not managing active processes

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

## 7) Weekly Verification Checklist
- Run `openclaw status --deep`
- Verify service manager consistency (systemd vs PM2)
- Verify public ports (`ss -ltnup`) against intended exposure list
- Validate Docker stack health (`docker ps`)
- Update this file if topology/ports/services changed
