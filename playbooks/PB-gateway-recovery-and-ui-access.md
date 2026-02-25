# PB: Gateway Recovery and UI Access

Mission: Ensure the OpenClaw Gateway is stable, accessible via the UI, and persistent across reboots.

## 1) Primary Operation (systemd)
The gateway is managed as a systemd service. This is the preferred way to start/stop the process.

**Commands:**
- Start: \systemctl start openclaw-gateway- Stop: \systemctl stop openclaw-gateway- Restart: \systemctl restart openclaw-gateway- Status: \systemctl status openclaw-gateway --no-pager -l
**Emergency Only (Manual nohup):**
Manual start via nohup is discouraged as it is not managed by the system and won't restart on crash/reboot.
\sudo -u agentadmin nohup /usr/bin/openclaw gateway --port 18791 --force > /home/agentadmin/openclaw-gateway.log 2>&1 &
## 2) Gateway Connection
- UI URL: https://agent.getvoidra.com
- Local Port: 18791 (127.0.0.1)

## 3) Failure signatures
- \origin not allowed\ -> allowedOrigins incomplete/wrong
- \Proxy headers detected from untrusted address\ -> trustedProxies missing
- \unauthorized: gateway token mismatch\ -> wrong UI token

## 4) Permissions repair (workspace)
\\ash
sudo chown -R agentadmin:agentadmin /home/agentadmin/.openclaw/workspace
find /home/agentadmin/.openclaw/workspace -type d -exec chmod 755 {} \;
find /home/agentadmin/.openclaw/workspace -type f -exec chmod 644 {} \;
\
## 5) Single source of truth rule
- Operate gateway consistently as \gentadmin\.
- Use systemd service for persistence and stability.
- Avoid parallel start loops from multiple shells/users.

## 6) Verification checklist (Post-start Evidence)
Run these to verify a healthy gateway:
- [x] Service status active: \systemctl status openclaw-gateway- [x] Port listening: \lsof -nP -iTCP:18791 -sTCP:LISTEN- [x] Health check OK: \curl -sS -D- http://127.0.0.1:18791/health\ (Look for Title: OpenClaw Control)
- [x] No orphaned processes: \ps -ef | grep openclaw | grep -v grep\ (Should only see systemd-managed process)
