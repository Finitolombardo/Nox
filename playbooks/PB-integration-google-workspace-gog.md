# PB-integration-google-workspace-gog.md

## Status
- Status: BROKEN
- Last checked: 2026-02-25 17:19:57 UTC
- Gmail Quick-Test (limit=1): `sudo -u agentadmin gog gmail search "in:inbox" --max=1 --json --no-input --account admin@alphamindhub.com` -> FAILED
- Drive Quick-Test (limit=1): `sudo -u agentadmin gog drive ls --max=1 --json --no-input --account admin@alphamindhub.com` -> FAILED
- Error (both): `OAuth client credentials missing (OAuth client ID JSON)... expected at /home/agentadmin/.config/gogcli/credentials.json`
- Evidence:
  - `sudo -u agentadmin gog --help` shows config path `/home/agentadmin/.config/gogcli/config.json`
  - `sudo -u agentadmin gog status --json --no-input` => `"credentials_exists": false`

## Scope
This playbook covers Google Workspace via the "gog" skill:
- Gmail
- Drive
- Sheets

## Quick-Tests
### Gmail Quick-Test
- Action: `sudo -u agentadmin gog gmail search "in:inbox" --max=1 --json --no-input --account <mail>`
- Expected: success (empty result allowed)

### Drive Quick-Test
- Action: `sudo -u agentadmin gog drive ls --max=1 --json --no-input --account <mail>`
- Expected: success

## Known-good configuration (NO secrets)
- credentials path: `/home/agentadmin/.config/gogcli/credentials.json`
- account configured in gog auth store

## Fix
1) Put OAuth client JSON at `/home/agentadmin/.config/gogcli/credentials.json`
2) `sudo -u agentadmin gog auth credentials /home/agentadmin/.config/gogcli/credentials.json`
3) `sudo -u agentadmin gog auth add admin@alphamindhub.com --services gmail,drive,sheets`
4) Re-run Gmail + Drive Quick-Tests

## Update policy
- Only set WORKING/BROKEN after tests run in this session.
- If test not executed: set UNVERIFIED with exact reason.

## Status (Audited)
- Status: WORKING (agentadmin)
- Last checked: 2026-02-25
- Required:
  - OAuth credentials type: **installed** (Desktop) in `credentials.json`
  - Keyring backend pinned: `gog auth keyring file`
  - Non-interactive runs: set `GOG_KEYRING_PASSWORD` in environment (do not print it)
- Root cause (previous failures):
  - `redirect_uri_mismatch` due to using web/invalid creds for dynamic localhost callback
  - `No tokens stored` because keyring backend was `auto` and config was not persisted (`config_exists false`)
- Fix summary:
  - Use installed creds → `gog auth credentials set ...`
  - Pin keyring → `gog auth keyring file` (creates `config.json`, `config_exists true`)
  - Complete OAuth consent via SSH tunnel for callback port
- Evidence (sanitized):
  - `gog auth status` → `config_exists true`, `keyring_backend file`
  - `gog auth list --plain` shows `admin@alphamindhub.com` with services `drive,gmail`
  - Gmail Quick-Test:
    - `gog gmail search "newer_than:7d" --limit 3 --plain` → returns message rows (drafts shown)
  - Drive Quick-Test:
    - `gog drive ls --limit 3 --plain` → returns file rows

## Quick-Tests
- Auth list: `gog auth list --plain`
- Gmail: `gog gmail search "newer_than:7d" --limit 3 --plain`
- Drive: `gog drive ls --limit 3 --plain`
