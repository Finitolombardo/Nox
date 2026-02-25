# PB-integration-todoist.md

## Status
- Status: WORKING
- Last checked: 2026-02-25 17:54 UTC
- Quick-Test:
  - `todoist auth <token>`
  - `todoist today`
- Result: SUCCESS (task list returned)
- Evidence:
  - `✓ Token saved to /root/.config/todoist-cli/config.json`
  - Output snippet from `todoist today`:
    - `6g4pmCxr52rjMQR5  [48h Cash Sprint] ... (today)`
    - `6g4pmF467CvhqXX5  [48h Cash Sprint] ... (today)`

## Quick-Test
- List today's tasks: `todoist today`
- Expected: task list output (or empty list without auth error)

## Known-good configuration (no secrets)
- Auth file path (current runtime user): `/root/.config/todoist-cli/config.json`
- Alternative env auth: `TODOIST_API_TOKEN`

## If broken
- `Error: Not authenticated.`
Fix steps:
1) Run `todoist auth <your-api-token>`
2) Re-run `todoist today`
3) If success, set Status=WORKING with timestamp and output snippet
