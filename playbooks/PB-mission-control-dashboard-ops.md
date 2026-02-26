# PB-mission-control-dashboard-ops

## Zweck
Standard Operating Procedure (SOP), um Mission Control (MC) + OpenClaw Gateway + Agents stabil zu betreiben, Agent-Provisioning-Probleme zu beheben, Token/Auth-Probleme zu lösen, und die Infrastruktur schnell zu recovern. Dieses Playbook enthält KEINE Secrets. Tokens werden nur referenziert (wo finden/rotieren).

## Architektur (Source of Truth)
- Mission Control Frontend: https://mc.getvoidra.com
- Mission Control Backend (intern): http://127.0.0.1:8000
- Nginx Proxy:
  - /api -> http://127.0.0.1:8000
  - Ergebnis: Externe API Pfade sind effektiv unter:
    - https://mc.getvoidra.com/api/api/v1/...
- Gateway:
  - systemd: openclaw-gateway.service
  - Port: 18791 (WebSocket)
  - State dir: /home/agentadmin/.openclaw (OPENCLAW_STATE_DIR)

## Auth-Modelle (wichtig)

### 1) User/Admin API (MC)
- Header: Authorization: Bearer <LOCAL_AUTH_TOKEN>
- Zweck: Gateways verwalten, templates sync, org/admin operations
- Quelle: /opt/openclaw/openclaw-mission-control/.env (AUTH_MODE=local, LOCAL_AUTH_TOKEN=...)

### 2) Agent API (MC)
- Header: X-Agent-Token: <AUTH_TOKEN>
- Zweck: Agent-scoped endpoints (/api/v1/agent/...)
- Tokens liegen pro Agent-Workspace in TOOLS.md als AUTH_TOKEN=...
- Tokens werden NICHT aus DB gelesen (DB hat nur Hash). Tokens werden über templates/sync rotiert.

### 3) Gateway Auth (OpenClaw Gateway)
- Gateway CLI supports: --auth token|password und --token <token> oder env OPENCLAW_GATEWAY_TOKEN
- Env file: /etc/openclaw/secrets.env
- systemd override setzt ExecStart mit --auth token (falls Device Identity errors auftreten).

## Wichtige Pfade
- Mission Control deploy: /opt/openclaw/openclaw-mission-control
- Gateway state root: /home/agentadmin/.openclaw
- Gateway workspace: /home/agentadmin/.openclaw/workspace-gateway-<gateway_id>/
- Lead workspace: /home/agentadmin/.openclaw/workspace-lead-<board_id>/ oder /home/agentadmin/.openclaw/workspace-mc-<agent_id>/
- MC-managed agent workspace: /home/agentadmin/.openclaw/workspace-mc-<agent_id>/

## Standard: “Everything Online” Checks

### A) Infrastruktur
1) MC backend health:
   - curl -sS http://127.0.0.1:8000/healthz
2) Containers:
   - cd /opt/openclaw/openclaw-mission-control && docker compose ps
3) Gateway service:
   - systemctl status openclaw-gateway --no-pager

### B) Gateway Reachability aus MC (wichtig)
- Wenn MC logs ConnectionRefusedError bei gateway_rpc:
  - Ursache meist: falsche Gateway URL (host.docker.internal auf Linux unzuverlässig)
  - Fix: Gateway URL auf ws://172.20.0.1:18791 setzen (Docker bridge gateway aus Container-Sicht)

## Häufige Fehlerbilder + Fix

### 1) “Internal Server Error” im Dashboard
Symptom:
- Backend logs: FATAL database "mission_control" does not exist
Fix:
- DB erstellen:
  - docker exec -i openclaw-mission-control-db-1 psql -U postgres -c "CREATE DATABASE mission_control;"
- backend restart:
  - docker compose restart backend
Hinweis: DB-Neuanlage bedeutet: MC Daten sind leer (Boards/Agents/Gateways neu anlegen).

### 2) Agents stuck “PROVISIONING” / OFFLINE
Ursachen:
- Templates sync hat keine gültigen AUTH_TOKEN in TOOLS.md
- BASE_URL Platzhalter in Workspaces (REPLACE_WITH_BASE_URL)
- Token mismatch (rotated, aber Workspace/Agent noch alt)
Fix (robust):
1) Templates sync lokal ohne nginx timeout:
   - curl -X POST "http://127.0.0.1:8000/api/v1/gateways/<gateway_id>/templates/sync?reset_sessions=true&rotate_tokens=true" \
     -H "Authorization: Bearer <LOCAL_AUTH_TOKEN>"
2) BASE_URL Platzhalter entfernen in allen Workspace markdowns:
   - find /home/agentadmin/.openclaw/workspace-* -type f -name "*.md" -print0 \
     | xargs -0 sed -i 's|REPLACE_WITH_BASE_URL|https://mc.getvoidra.com/api|g'
3) Presence/Last-seen forcieren:
   - Token aus passendem workspace-*/TOOLS.md holen (AUTH_TOKEN)
   - curl -H "X-Agent-Token: <AUTH_TOKEN>" https://mc.getvoidra.com/api/api/v1/agent/boards

### 3) 401 Unauthorized bei Agent-API Calls
Ursachen:
- Token outdated (nach rotate_tokens)
- falscher Workspace (mehrere lead/gateway workspaces existieren)
Fix:
- Richtigen Workspace finden via AGENT_ID search:
  - grep -RIn "AGENT_ID=<agent_id>" /home/agentadmin/.openclaw/workspace-* | head
- Token aus dem gefundenen workspace/.../TOOLS.md nehmen
- Wenn weiterhin 401: rotate_tokens=true + reset_sessions=true erneut (lokal über 127.0.0.1)

### 4) 403 “Only board leads can perform this action”
Bedeutung:
- Du benutzt Gateway/Main oder Worker Token für write actions (create subtasks etc).
Fix:
- Für Board-Write braucht es Lead Token (Lead workspace).
- Workaround (wenn Lead write scope spinnt): Subtasks manuell im UI erstellen und nur Worker assignen.

### 5) 504 Gateway Time-out bei templates/sync
Bedeutung:
- Nginx timeout, backend braucht länger (Gateway-RPC, retries).
Fix:
- Immer lokal callen:
  - http://127.0.0.1:8000/api/v1/gateways/<gateway_id>/templates/sync?...

### 6) “device identity required” beim Gateway connect
Bedeutung:
- Gateway verlangt device identity/pairing oder token auth.
Fix:
- In /etc/openclaw/secrets.env:
  - OPENCLAW_GATEWAY_TOKEN=<random>
- systemd override:
  - sudo systemctl edit openclaw-gateway
    [Service]
    ExecStart=
    ExecStart=/usr/bin/openclaw gateway --port 18791 --force --auth token
- daemon reload + restart:
  - sudo systemctl daemon-reload
  - sudo systemctl restart openclaw-gateway
- Dann Gateway token im MC Gateway Record entsprechend setzen (ohne Tokens in Logs/Tasks).

## Recovery Playbook: “Bring alles wieder hoch”
1) Gateway erreichbar machen:
   - systemctl status openclaw-gateway
2) MC backend health:
   - curl http://127.0.0.1:8000/healthz
3) Gateway URL korrekt setzen:
   - bevorzugt ws://172.20.0.1:18791
4) templates/sync lokal:
   - rotate_tokens=true & reset_sessions=true
5) Placeholder scrub:
   - replace REPLACE_WITH_BASE_URL in workspace-*.md
6) Presence ping Lead + Worker + Gateway Agent:
   - X-Agent-Token -> /api/api/v1/agent/boards

## Security Regeln
- Niemals AUTH_TOKEN, LOCAL_AUTH_TOKEN, OPENCLAW_GATEWAY_TOKEN in Tasks/Comments/Memory speichern.
- Tokens rotieren nach Exposure:
  - templates/sync?rotate_tokens=true
- Secrets bleiben in:
  - /opt/openclaw/openclaw-mission-control/.env (LOCAL_AUTH_TOKEN)
  - /etc/openclaw/secrets.env (OPENCLAW_GATEWAY_TOKEN, andere)
- Logs können sensitive Data enthalten: sparsam teilen.

## Evidence Standard
Wenn ein Incident passiert:
- Backend logs snippet (tail 120 lines)
- Gateway status
- templates/sync response JSON (errors)
- Welche Workspaces betroffen (workspace paths), ohne Tokens

## Owned-by
- Board Lead: Almanexia
- Worker: Zappwrench Geargrit