#!/usr/bin/env bash
set -euo pipefail
ALERT_FILE="/home/agentadmin/.openclaw/workspace/memory/backup-alert.flag"
if [ -s "$ALERT_FILE" ]; then
  echo "ALERT: $(cat "$ALERT_FILE")"
else
  echo "HEARTBEAT_OK"
fi
