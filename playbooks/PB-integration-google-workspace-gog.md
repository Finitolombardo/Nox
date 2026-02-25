# PB-integration-google-workspace-gog.md

## Status
- Status: BROKEN
- Last checked: 2026-02-25 16:21 UTC
- Gmail Quick-Test (limit=1): `gog gmail search 'in:inbox' --max 1 --json --no-input` → FAIL (`read token: aes.KeyUnwrap(): integrity check failed`)
- Drive Quick-Test (limit=1): `gog drive search '*' --max 1 --json --no-input` → FAIL (`read token: aes.KeyUnwrap(): integrity check failed`)
- Likely cause: corrupted/unreadable local gog OAuth token store for account `admin@alphamindhub.com`
- Fix: re-auth gog (`gog auth list`, then `gog auth add admin@alphamindhub.com --services gmail,drive`), retry tests

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
