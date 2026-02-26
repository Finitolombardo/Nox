# Secrets Inventory (Redacted, No Secret Values)

Last updated: 2026-02-24 UTC
Policy: Do not store raw credentials in chat or plain-text docs.

## Known Secret Classes
- Telegram bot token (OpenClaw channel config)
- API keys for external services used by workflows (n8n / app stacks)
- Database credentials (Postgres/Redis/app env)
- Session/auth tokens used by gateway and automation services

## Storage Locations to Audit (names only)
- OpenClaw user systemd unit env references (`/root/.config/systemd/user/openclaw-gateway.service`)
- n8n systemd unit env references (`/etc/systemd/system/n8n.service`)
- Docker/container env blocks (`docker inspect` + deployment manifests)
- OpenClaw data/config under `/mnt/HC_Volume_103972109/openclaw_data`
- n8n credentials/data under `/mnt/HC_Volume_103972109/n8n_data`
- CI/deploy secret stores (if configured)

## Required Tracking Fields (per secret)
- `secret_name`
- `owner_service`
- `storage_location`
- `last_rotated_at`
- `rotation_interval_days`
- `status` (ok / due / expired)

## Immediate Findings
- Plaintext credentials are currently embedded via `Environment=` entries in at least one systemd unit.
- This is operationally convenient but high-risk (unit file reads leak credential material).
- Recommended next step: migrate secrets to `EnvironmentFile=` with strict file permissions (`0600`) and rotate exposed keys.

## Security Rule
- Never exfiltrate or paste secret values into Telegram/chat.
- If needed operationally, rotate + rebind secrets through approved secure stores only.
