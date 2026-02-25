# PB-integration-google-workspace-gog.md

## Status
- Status: UNVERIFIED (non-interactive agentadmin check without env)
- Last checked: 2026-02-25 22:32:00 UTC
- Quick-Test: `sudo -u agentadmin env HOME=/home/agentadmin XDG_CONFIG_HOME=/home/agentadmin/.config GOG_KEYRING_PASSWORD="$GOG_KEYRING_PASSWORD" gog auth list --plain`
- Result: UNVERIFIED
- Error: Missing keyring environment context.
- Update logic: If `aes.KeyUnwrap` or `no TTY available` appears, set status to UNVERIFIED (missing env), not BROKEN. Only set BROKEN if auth list fails with correct env injection.

## Scope
This playbook covers Google Workspace via the "gog" skill:
- Gmail
- Drive
- Sheets
- Calendar
- Contacts
- Docs

## Failure modes (non-issues)
Do NOT report these as broken OAuth. They are expected environment missing errors in headless contexts:
- `aes.KeyUnwrap(): integrity check failed` = wrong/missing `GOG_KEYRING_PASSWORD` or wrong `HOME`/`XDG` context.
- `no TTY available...` = missing `GOG_KEYRING_PASSWORD` in headless run.

## Standard headless wrapper
When running via sudo/CI (no TTY), always inject HOME/XDG + keyring password env:

```bash
sudo -u agentadmin env HOME=/home/agentadmin XDG_CONFIG_HOME=/home/agentadmin/.config GOG_KEYRING_PASSWORD="$GOG_KEYRING_PASSWORD" gog <command>
```

Example (Drive):
`sudo -u agentadmin env HOME=/home/agentadmin XDG_CONFIG_HOME=/home/agentadmin/.config GOG_KEYRING_PASSWORD="$GOG_KEYRING_PASSWORD" gog drive ls --max=3 --plain --no-input --account admin@alphamindhub.com`

Example (Auth list):
`sudo -u agentadmin env HOME=/home/agentadmin XDG_CONFIG_HOME=/home/agentadmin/.config GOG_KEYRING_PASSWORD="$GOG_KEYRING_PASSWORD" gog auth list --plain`

## Quick-Tests
### Gmail Quick-Test
- Action: `sudo -u agentadmin env HOME=/home/agentadmin XDG_CONFIG_HOME=/home/agentadmin/.config GOG_KEYRING_PASSWORD="$GOG_KEYRING_PASSWORD" gog gmail search "in:inbox" --max=1 --json --no-input --account admin@alphamindhub.com`
- Expected: success (empty result allowed)

### Drive Quick-Test
- Action: `sudo -u agentadmin env HOME=/home/agentadmin XDG_CONFIG_HOME=/home/agentadmin/.config GOG_KEYRING_PASSWORD="$GOG_KEYRING_PASSWORD" gog drive ls --max=1 --json --no-input --account admin@alphamindhub.com`
- Expected: success

## Known-good configuration (NO secrets)
- credentials path: `/home/agentadmin/.config/gogcli/credentials.json`
- OAuth credentials type: **installed** (Desktop)
- Keyring backend pinned: `gog auth keyring file`
- Non-interactive runs: set `GOG_KEYRING_PASSWORD` in environment (do not print it)

## Fix (Initial Setup)
1) Put OAuth client JSON at `/home/agentadmin/.config/gogcli/credentials.json`
2) `sudo -u agentadmin gog auth credentials /home/agentadmin/.config/gogcli/credentials.json`
3) `sudo -u agentadmin gog auth add admin@alphamindhub.com --services gmail,drive,sheets`
4) Pin keyring: `gog auth keyring file`
5) Re-run Quick-Tests with env injection.
