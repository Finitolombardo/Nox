# Heartbeat Monitoring System

## Warning
**Do NOT paste cron lines into the terminal.**

## Cron Schedule
```bash
10 7 * * * /home/agentadmin/.openclaw/workspace/heartbeat/heartbeat.sh >/home/agentadmin/.openclaw/workspace/heartbeat/cron.log 2>&1
0 6,9,12,15,18,21 * * * /home/agentadmin/.openclaw/workspace/heartbeat/heartbeat.sh >/home/agentadmin/.openclaw/workspace/heartbeat/cron.log 2>&1
```

## Installation Steps
To install cron jobs, use:
```bash
crontab -e
crontab -l
```

## Quick Test
Run the following command to test the heartbeat script:
```bash
/home/agentadmin/.openclaw/workspace/heartbeat/heartbeat.sh --now
```