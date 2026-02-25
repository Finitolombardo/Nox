# PB-integration-n8n.md

## Status
- Status: WORKING
- Last checked: 2026-02-25
- Quick-Test: `curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" $N8N_URL/api/v1/workflows?limit=1`
- Result: SUCCESS (returned workflow data)

## Scope
This playbook covers the connection to the user's remote n8n instance.
- Workflows orchestration
- Campaign automation syncing

## Known-good configuration (NO secrets)
- **URL:** `https://n8n.getvoidra.com`
- **Auth:** JWT / API Key via `X-N8N-API-KEY` header
- **API Version:** `/api/v1/`

## Quick-Tests
### List Workflows
- Action: `curl -s -H "X-N8N-API-KEY: <key>" https://n8n.getvoidra.com/api/v1/workflows?limit=1`
- Expected: Returns a JSON object containing a `data` array with workflow definitions.

## Daily Operations / Usage
- Reference this playbook when interacting with the remote n8n instance for the campaign evolution strategies outlined in `n8n-campaign-evolution.md`.
