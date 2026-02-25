# PB-integration-google-workspace-gog.md

## Status
- Status: BROKEN
- Last checked: 2026-02-25 17:11:52 UTC
- Gmail Quick-Test (limit=1): `gog gmail search "in:inbox" --max=1 --json --no-input` -> FAILED
- Drive Quick-Test (limit=1): `gog drive ls --max=1 --json --no-input` -> FAILED
- Error (both): `token source: get token for admin@alphamindhub.com: read token: aes.KeyUnwrap(): integrity check failed.`
- Likely cause: Token/keyring/config drift (current gog config path resolves to `/root/.config/gogcli`, not agentadmin profile)
- Evidence: `gog status --json --no-input` shows credentials_path `/root/.config/gogcli/credentials.json` (2026-02-25 17:11 UTC)
- Fix:
  1) Run gog under the intended user profile consistently (agentadmin)
  2) Re-auth that profile (`gog auth add <account> --services gmail,drive,sheets`)
  3) Re-run the two Quick-Tests above
## Scope
This playbook covers Google Workspace via the "gog" skill:
- Gmail
- Drive
- Sheets
(Optionally: Calendar, Contacts, Docs if enabled)

## Quick-Tests (pick the minimum needed)
### Gmail Quick-Test
- Action: list/search INBOX (limit=1)
- Expected: success (even empty results are ok)

### Drive Quick-Test
- Action: list 1 item in Drive root (limit=1)
- Expected: success

### Sheets Quick-Test
- Action: read sheet metadata OR read 1 cell range (limit=1)
- Expected: success

## Known-good configuration (NO secrets)
- Skill: gog (steipete)
- OAuth profile label: (fill after success)
- Required scopes: (fill after success)
- Project requirement: if errors mention project/quota, set GOOGLE_CLOUD_PROJECT or GOOGLE_CLOUD_PROJECT_ID

## If broken (common)
- OAuth expired: re-login OAuth
- 403 scope missing: re-auth with correct scopes
- Project/quota error: set GOOGLE_CLOUD_PROJECT(_ID)
- 404 file/sheet id: wrong ID

## Update policy
- On success: set Status=WORKING, Last checked=timestamp, note which test passed.
- On failure: set Status=BROKEN, include exact error, write INCIDENT to memory (short).
