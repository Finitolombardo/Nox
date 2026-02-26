# PB-integration-todoist.md

## Status
- Status: WORKING
- Last checked: 2026-02-25 18:01 UTC
- Quick-Test (agentadmin): `sudo -u agentadmin bash -lc 'todoist today | head -n 8'`
- Result: SUCCESS (task list returned under agentadmin)

## Evidence (sanitized)
- Pre-fix failure:
  - `sudo -u agentadmin bash -lc 'whoami; todoist today'`
  - Output: `agentadmin` + `Error: Not authenticated.`
- Config files after fix:
  - `ls -la /root/.config/todoist-cli/config.json /home/agentadmin/.config/todoist-cli/config.json`
  - Output:
    - `-rw------- 1 root       root       ... /root/.config/todoist-cli/config.json`
    - `-rw------- 1 agentadmin agentadmin ... /home/agentadmin/.config/todoist-cli/config.json`
- Post-fix success (agentadmin):
  - Output snippet: `6g4pmCxr52rjMQR5 ... (today)`

## Known-good configuration (no secrets)
- Required for stable ops: `/home/agentadmin/.config/todoist-cli/config.json` (owner `agentadmin`)
- Root config may exist (`/root/.config/todoist-cli/config.json`) but is **NOT acceptable** as sole auth source for stable ops.
- Alternative auth method: `TODOIST_API_TOKEN` + `todoist auth "$TODOIST_API_TOKEN"` as `agentadmin`.

## Quick-Test
- `sudo -u agentadmin bash -lc 'todoist today | head -n 8'`
- Expected: task list output, no auth error

## If broken
1) Ensure token is available in agentadmin shell (do not print token)
2) Run as agentadmin: `todoist auth "$TODOIST_API_TOKEN"`
3) Re-run quick-test above
4) Verify ownership: `ls -la /home/agentadmin/.config/todoist-cli/config.json`
