# PB-integration-google-workspace-gog.md

## Status
- Status: WORKING (verified with headless wrapper)
- Last checked: 2026-02-26
- Quick-Test: `sudo -n /usr/local/bin/gog-headless auth list --plain`
- Result: SUCCESS

## Scope
This playbook covers Google Workspace via the "gog" skill:
- Gmail
- Drive
- Sheets
- Calendar
- Contacts
- Docs

## Standard headless wrapper (MANDATORY)
**All** `gog` commands MUST be executed using the dedicated `gog-headless` wrapper with `sudo -n`. This wrapper automatically sources `/etc/openclaw/secrets.env` to provide the required `GOG_KEYRING_PASSWORD` without interactive prompts or secret leakage.

```bash
sudo -n /usr/local/bin/gog-headless <command> [flags]
```

**CRITICAL RULES:**
1. Never use `gog` directly.
2. Never use `sudo` without `-n`.
3. Always use `--plain` and `--no-input` to prevent interactive hangs.
4. Always pass the account explicitly: `--account admin@alphamindhub.com`

**Examples:**
- **Auth list:** `sudo -n /usr/local/bin/gog-headless auth list --plain`
- **Drive LS:** `sudo -n /usr/local/bin/gog-headless drive ls --max=3 --plain --no-input --account admin@alphamindhub.com`
- **Sheets metadata:** `sudo -n /usr/local/bin/gog-headless sheets metadata <ID> --account admin@alphamindhub.com --json`

## Failure modes & Triage
If a call fails, check the exact error:
- `sudo: a terminal is required` or `password is required` ➔ `sudo -n` is missing or sudoers misconfigured.
- `aes.KeyUnwrap(): integrity check failed` ➔ The keyring password in `/etc/openclaw/secrets.env` is wrong or corrupt (assuming `gog-headless` was used correctly). Status becomes UNVERIFIED.
- `403/404` ➔ Drive permissions issue or wrong File ID.

## Known-good configuration
- credentials path: `/home/agentadmin/.config/gogcli/credentials.json`
- OAuth credentials type: **installed** (Desktop)
- Keyring backend pinned: `gog auth keyring file`
- Sudoers allows `agentadmin` to run `/usr/local/bin/gog-headless` as root without a password.