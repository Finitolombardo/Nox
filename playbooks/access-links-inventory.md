# Access & Endpoint Inventory

Last updated: 2026-02-24 UTC

## Local Control Endpoints
- OpenClaw Dashboard (local): `http://127.0.0.1:18791/`
- OpenClaw internal ports: `127.0.0.1:18793`, `127.0.0.1:18794`

## Public Endpoints (observed listeners)
- HTTP ingress: `:80` (nginx)
- HTTPS ingress: `:443` (nginx)
- SSH: `:22`
- Firecrawl API exposure: `:3002`

## Internal/Loopback Monitoring Endpoints
- Prometheus: `127.0.0.1:9090`
- Node Exporter: `127.0.0.1:9100`
- Blackbox Exporter: `127.0.0.1:9115`
- cAdvisor: `127.0.0.1:8080`
- Grafana (tailnet bind): `100.101.39.72:3000`

## Integration Endpoints
- Telegram integration: enabled in OpenClaw

## Validation Commands
- `openclaw status --deep`
- `ss -ltnup`
- `docker ps`
