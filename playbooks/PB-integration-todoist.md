# PB-integration-todoist.md

## Status
- Status: BROKEN
- Last checked: 2026-02-25 17:53:00 UTC
- Quick-Test: `todoist today`
- Result: FAILED (not authenticated)
- Error: `Error: Not authenticated. Run: todoist auth <your-api-token> or set TODOIST_API_TOKEN=<your-token>`
- Evidence:
  - Skill installed: `/home/agentadmin/.openclaw/workspace/skills/todoist/SKILL.md`
  - CLI installed: `npm install -g todoist-ts-cli@^0.2.0` completed successfully

## Quick-Test
- List today's tasks: `todoist today`
- Expected: task list output (or empty list without auth error)

## Known-good configuration (no secrets)
- Required env: `TODOIST_API_TOKEN`
- Alternative auth: `todoist auth <api-token>`

## Fix steps
1) Generate API token: https://todoist.com/app/settings/integrations/developer
2) Authenticate (one of):
   - `todoist auth <your-api-token>`
   - `export TODOIST_API_TOKEN=<your-token>`
3) Re-run quick-test: `todoist today`
4) If success, set Status=WORKING with timestamp and output snippet
