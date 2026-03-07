# PB-integration-notion.md

## Status
- Status: WORKING
- Last checked: 2026-03-07 17:35:00 UTC
- Quick-Test: SUCCESS (verified API connection and Database properties)
- Reason: Notion API Key and Database ID found in environment variables. Successfully created 3 Quests.
- Result: WORKING

## What "working" means (Quick-Test)
- Query: fetch 1 item from Quest/Tasks DB (limit=1)
- Expected: success response (HTTP 200 equivalent)

## Known-good configuration (no secrets)
- Notion integration: (name/label)
- Quest/Tasks DB ID: (fill after first successful test)
- Required properties:
  - Status
  - Responsible/Nox
  - Title

## If broken
Common errors:
- 401/403: token/permissions (integration not shared)
- 404: wrong DB ID
Fix steps:
1) Verify integration access to DB/page
2) Verify DB ID
3) Re-auth/refresh token
