#!/bin/sh

# Heartbeat Monitoring Script

# Collect metrics
DATE=$(date)
UPTIME=$(uptime)
DISK_USAGE=$(df -h /)
MEMORY=$(free -h)
LOAD=$(uptime | awk -F'load average:' '{ print $2 }')
DOCKER_STATUS=
"$(docker ps --format '{{.Names}}: {{.Status}}' | grep -E 'openclaw-gateway|openclaw-cli')"

# Log scan
LOG_SCAN=$(tail -n 200 ~/.openclaw/gateway.log | grep -E 'rate limit|429|timeout|ECONN|gateway closed|invalid spec')

# State file path
STATE_FILE=~/\.openclaw/workspace/heartbeat/heartbeat_state.json

# Read last alert hash and timestamp
if [ -f "$STATE_FILE" ]; then
    LAST_ALERT=$(jq -r '.last_alert' "$STATE_FILE")
    LAST_TIMESTAMP=$(jq -r '.last_timestamp' "$STATE_FILE")
else
    LAST_ALERT=""
    LAST_TIMESTAMP=""
fi

# Generate report
REPORT="Timestamp: $DATE\nUptime: $UPTIME\nDisk Usage: $DISK_USAGE\nMemory: $MEMORY\nLoad: $LOAD\nDocker Status: $DOCKER_STATUS\nLog Issues: $LOG_SCAN\n"

# Hash the report
CURRENT_HASH=$(echo "$REPORT" | md5sum | cut -d' ' -f1)

# Check for changes
if [ "$CURRENT_HASH" != "$LAST_ALERT" ]; then
    # Update state file
    echo "{\"last_alert\": \"$CURRENT_HASH\", \"last_timestamp\": \"$DATE\"}" > "$STATE_FILE"
    echo "$REPORT"
fi