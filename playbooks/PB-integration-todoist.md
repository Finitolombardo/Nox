# PB-integration-todoist.md

## Status
- Status: UNVERIFIED
- Last checked: 2026-02-25 17:19:57 UTC
- Quick-Test: NOT RUN (no Todoist execution tool available in this agent runtime)
- Reason: this session tool registry has no Todoist tool endpoint; `openclaw status --deep | grep -Ei 'notion|todoist|gog'` returned no Todoist tool entry
- Result: keep UNVERIFIED until a live Todoist API call (limit=5) is executed

## Quick-Test
- List 5 active tasks (limit=5)
- Expected: success response (HTTP 200 equivalent)

## Known-good configuration (no secrets)
- Account/email: (optional)
- Default project: (optional)

## If broken
- 401: token invalid/expired
- 403: permissions
Fix steps:
1) Update token in skill/env
2) Re-test
