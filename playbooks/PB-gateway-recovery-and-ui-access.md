# PB-gateway-recovery-and-ui-access.md

## Zweck
Runbook für "Gateway wirkt offline / UI kommt nicht zurück" mit evidenzbasierter Recovery.

## 1) Health Checks (read-only)
```bash
ps -ef | grep -E 'openclaw-gateway|openclaw .* gateway' | grep -v grep
ss -ltnp | grep 18791 || true
openclaw status

tail -n 120 /home/agentadmin/openclaw-gateway.log
tail -n 120 /tmp/openclaw/openclaw-$(date -u +%F).log 2>/dev/null || true
tail -n 120 /tmp/openclaw-0/openclaw-$(date -u +%F).log 2>/dev/null || true
```

## 2) Safe restart (manual, single instance)
```bash
# stop all existing gateway processes
pkill -f 'openclaw.*gateway' || true
sleep 2

# verify port is free
ss -ltnp | grep 18791 || echo 'port free'

# start as agentadmin in background
sudo -u agentadmin nohup openclaw gateway run --port 18791 \
  > /home/agentadmin/openclaw-gateway.log 2>&1 &

# verify process + port + health
ps -ef | grep -E 'openclaw-gateway|openclaw .* gateway' | grep -v grep
ss -ltnp | grep 18791
tail -n 60 /home/agentadmin/openclaw-gateway.log
openclaw status
```

## 3) UI access controls
- `gateway.controlUi.allowedOrigins` must include the actual UI origin(s).
- If behind reverse proxy, set `gateway.trustedProxies`.
- After config changes: restart gateway and verify logs.

Failure signatures:
- `origin not allowed` -> allowedOrigins incomplete/wrong
- `Proxy headers detected from untrusted address` -> trustedProxies missing
- `unauthorized: gateway token mismatch` -> wrong UI token

## 4) Permissions repair (workspace)
```bash
sudo chown -R agentadmin:agentadmin /home/agentadmin/.openclaw/workspace
find /home/agentadmin/.openclaw/workspace -type d -exec chmod 755 {} \;
find /home/agentadmin/.openclaw/workspace -type f -exec chmod 644 {} \;
```

## 5) Single source of truth rule
- Operate gateway consistently as `agentadmin`.
- Avoid mixed runtime state between `/root/.openclaw` and `/home/agentadmin/.openclaw`.
- No parallel start loops from multiple shells/users.

## 6) Verification checklist
- [ ] Exactly one listener on `127.0.0.1:18791`
- [ ] `openclaw status` shows gateway reachable
- [ ] No new `origin not allowed` in logs
- [ ] No new `token mismatch` in logs
- [ ] No `EACCES` on workspace files
- [ ] UI stays connected >2 minutes
