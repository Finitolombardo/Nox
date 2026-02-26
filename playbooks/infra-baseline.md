# Infra Baseline (Server: 91.99.172.36)

Last updated: 2026-02-24 UTC

## System
- Hostname: ubuntu-4gb-nbg1-2
- OS: Ubuntu 24.04.3 LTS
- Kernel: 6.8.0-100-generic
- Access: SSH key-based (root)

## Storage
- Root (`/dev/sda1`): 38G total, 25G used, 11G free, 71%
- Data volume (`/mnt/HC_Volume_103972109`): mounted and used for offloading caches/migrations

## Security posture
- UFW: active
- Inbound policy: deny (default)
- Allowed inbound: 22/tcp, 80/tcp, 443/tcp, 3002/tcp
- OpenClaw setting: `gateway.controlUi.allowInsecureAuth = false`
- OpenClaw security audit: `0 critical · 1 warn · 1 info`
- Remaining warning: `gateway.trusted_proxies_missing`

## Open ports (expected)
- 22/tcp (SSH)
- 80/tcp (HTTP)
- 443/tcp (HTTPS)
- 3002/tcp (Docker proxy)

## Recent hardening/actions
1. Disk pressure reduced from 95% to 71% by housekeeping + cache offloading to data volume.
2. UFW enabled with strict inbound allowlist.
3. Insecure OpenClaw control UI auth toggle disabled.

## Guardrails
- Phase B container storage migration remains blocked unless explicitly approved.
- JSON config edits require pre-flight validation before restart.
