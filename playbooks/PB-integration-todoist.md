# PB-integration-todoist.md

## Status
- Status: UNVERIFIED
- Last checked: 2026-02-25 17:11:52 UTC
- Quick-Test: Not possible in this runtime (no Todoist CLI/tool endpoint available for limit=5 task list)
- Result: Could not execute API call; status set to UNVERIFIED until a live query is run
- Evidence: `which todoist` -> not found (command output, 2026-02-25 17:11 UTC)

## Quick-Test
- List 5 active tasks (limit=5)
- Expected: HTTP 200 + array

## Known-good configuration (no secrets)
- Account/email: (optional)
- Default project: (optional)

## If broken
- 401: token invalid/expired
- 403: permissions
Fix steps:
1) Update token in skill/env
2) Re-test
