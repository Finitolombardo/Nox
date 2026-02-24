# Secrets Inventory (Redacted, No Secret Values)

Last updated: 2026-02-24 UTC
Policy: Do not store raw credentials in chat or plain-text docs.

## Known Secret Classes
- Telegram bot token (OpenClaw channel config)
- API keys for external services used by workflows (n8n / app stacks)
- Database credentials (Postgres/Redis/app env)
- Session/auth tokens used by gateway and automation services

## Storage Locations to Audit (names only)
- OpenClaw config/runtime env files
- systemd unit env references (`Environment=` / `EnvironmentFile=`)
- Docker compose/env files and container env blocks
- n8n credentials store and environment
- CI/deploy secret stores (if configured)

## Required Tracking Fields (per secret)
- `secret_name`
- `owner_service`
- `storage_location`
- `last_rotated_at`
- `rotation_interval_days`
- `status` (ok / due / expired)

## Security Rule
- Never exfiltrate or paste secret values into Telegram/chat.
- If needed operationally, rotate + rebind secrets through approved secure stores only.
