#!/bin/bash
# Quest Runner Automation Script - v3 Fixed (with Token)

QUEST_NAME=$1
COMMAND=$2
TOKEN="22f35642dfd435301e904c0f27690d55e9da29f0559838e8"

if [ -z "$QUEST_NAME" ] || [ -z "$COMMAND" ]; then
  echo "Usage: $0 <quest_name> <command>"
  exit 1
fi

# 0) Emit event: task.planned
openclaw system event --text "Quest Planned: $QUEST_NAME" --token $TOKEN

# 1) Execute command
echo "--- EXECUTION START: $QUEST_NAME ---"
eval "$COMMAND"
RESULT=$?
echo "--- EXECUTION END: $QUEST_NAME (Status: $RESULT) ---"

# 2) Update last_applied.json
export LAST_APPLIED="$HOME/.openclaw/memory/last_applied.json"
export TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
export QUEST_NAME
export RESULT

python3 -c "
import json, os
path = os.environ['LAST_APPLIED']
qname = os.environ['QUEST_NAME']
ts = os.environ['TIMESTAMP']
res = int(os.environ['RESULT'])

if not os.path.exists(os.path.dirname(path)):
    os.makedirs(os.path.dirname(path), exist_ok=True)
if not os.path.exists(path) or os.path.getsize(path) == 0:
    with open(path, 'w') as f:
        json.dump({'last_quest': None, 'last_updated': None, 'history': []}, f)

with open(path, 'r') as f:
    try:
        data = json.load(f)
    except Exception:
        data = {'last_quest': None, 'last_updated': None, 'history': []}

data['last_quest'] = qname
data['last_updated'] = ts
data['history'].append({'quest': qname, 'timestamp': ts, 'status': res})
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
"

# 3) Regenerate DASHBOARD.md
DASHBOARD="$HOME/.openclaw/workspace/DASHBOARD.md"
cat << EOD > $DASHBOARD
# OpenClaw Dashboard

*Last Updated: $TIMESTAMP*

## Current State
- **Last Quest:** $QUEST_NAME
- **Status: $RESULT**

## Recent Activity Feed
EOD

python3 -c "
import json, os
path = os.environ['LAST_APPLIED']
with open(path, 'r') as f:
    data = json.load(f)
for entry in reversed(data['history'][-10:]):
    status_icon = '?' if entry['status'] == 0 else '?'
    print(f'- {status_icon} **{entry[\"quest\"]}** @ {entry[\"timestamp\"]}')
" >> $DASHBOARD

# 4) Refresh Vault Index
~/.openclaw/workspace/skills/quest_runner/update_index.sh

# 5) Emit event: task.completed
openclaw system event --text "Quest Completed: $QUEST_NAME (Status: $RESULT)" --token $TOKEN

echo "--- PROOF BLOCK ---"
echo "Dashboard: $DASHBOARD"
tail -n 5 "$DASHBOARD"
