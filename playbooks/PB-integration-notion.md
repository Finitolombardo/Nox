# PB-integration-notion.md

## Status
- Status: UNVERIFIED
- Last checked: 2026-02-25 17:19:57 UTC
- Quick-Test: NOT RUN (no Notion execution tool available in this agent runtime)
- Reason: this session tool registry has no Notion tool endpoint; `openclaw status --deep | grep -Ei 'notion|todoist|gog'` returned no Notion tool entry
- Result: keep UNVERIFIED until a live Notion API call (limit=1) is executed

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
