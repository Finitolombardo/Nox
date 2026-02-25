# PB-integration-notion.md

## Status
- Status: UNVERIFIED
- Last checked: 2026-02-25 17:11:52 UTC
- Quick-Test: Not possible in this runtime (no Notion CLI/tool endpoint available for a limit=1 query)
- Result: Could not execute API call; status set to UNVERIFIED until a live query is run
- Evidence: `which notion` -> not found (command output, 2026-02-25 17:11 UTC)

## What "working" means (Quick-Test)
- Query: fetch 1 item from Quest/Tasks DB (limit=1)
- Expected: HTTP 200 + results array length >= 0

## Known-good configuration (no secrets)
- Notion integration: (name/label)
- Quest/Tasks DB ID: (fill after first successful test)
- Required properties:
  - Status: (allowed values)
  - Responsible/Nox: (allowed values)
  - Title: (name)
- Notes:
  - Integration must be shared with the DB/page

## If broken
Common errors:
- 401/403: token/permissions (integration not shared)
- 404: wrong DB ID
Fix steps:
1) Verify integration has access to the DB
2) Verify DB ID
3) Re-auth / refresh token