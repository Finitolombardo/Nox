#!/bin/bash
# Update Vault Index script

VAULT="$HOME/.openclaw/memory/stable/VAULT.md"
mkdir -p "$(dirname "$VAULT")"

echo "# OpenClaw Vault" > "$VAULT"
echo "" >> "$VAULT"
echo "## Quest Index (Automated)" >> "$VAULT"

# Aggregate from history
LAST_APPLIED="$HOME/.openclaw/memory/last_applied.json"
if [ -f "$LAST_APPLIED" ]; then
  python3 -c "
import json
with open('$LAST_APPLIED', 'r') as f:
    data = json.load(f)
for entry in data['history']:
    status_icon = '?' if entry['status'] == 0 else '?'
    print(f'- {entry['timestamp']} {status_icon} **{entry[\"quest\"]}**')
" >> "$VAULT"
fi

echo "" >> "$VAULT"
echo "---" >> "$VAULT"
echo "*Index rebuilt at $(date -u +'%Y-%m-%dT%H:%M:%SZ')*" >> "$VAULT"
