# Mission Control Agents Fix — Workbook

> **Date**: 2026-02-27  
> **Server**: root@91.99.172.36 (Hetzner, Ubuntu)  
> **Affected Stack**: OpenClaw Mission Control (`/opt/openclaw/openclaw-mission-control`)  
> **Gateway**: `openclaw-gateway.service` (systemd, loopback-only)

---

## TL;DR

Drei Agents im Mission Control Dashboard waren stuck (UPDATING / OFFLINE, last seen ~10h).
Ursache: drei Konfigurationsfehler in der MC-Datenbank (Tabelle `gateways`).

| # | Root Cause | Fix |
|---|-----------|-----|
| 1 | Gateway-URL `ws://172.20.0.1:18791` nicht erreichbar aus Docker (Gateway bindet nur auf loopback) | → `wss://agent.getvoidra.com` (über Nginx Proxy) |
| 2 | Token-Mismatch: DB hatte falschen Token | → Token aus `~/.openclaw/openclaw.json` übernommen |
| 3 | `allow_insecure_tls=false` inkompatibel mit `wss://` | → `true` gesetzt (TLS endet am lokalen Nginx) |

Alle Änderungen waren **nur in der MC PostgreSQL DB** — kein Gateway-Restart, keine Volume-Löschung, keine Config-Datei-Änderung.

---

## 1) Problem Statement

Das Mission Control Dashboard unter `https://mc.getvoidra.com/agents` zeigte 3 Agents mit:
- Status: **UPDATING** oder **OFFLINE**
- Last seen: **~10 Stunden** zurück
- Keine "Wake"-Buttons sichtbar

Die OpenClaw Gateway-Instanz (`agent.getvoidra.com`) sollte dabei NICHT verändert werden.

---

## 2) Symptoms & Evidence

### 2.1 Agent DB Records (vor dem Fix)

```
-[ RECORD 1 ]--------+-------------------------------------
id                   | 2f6256da-5254-4b09-89de-d19edf340883
name                 | Zappwrench Geargrit 🤖🔧
status               | online
last_seen_at         | 2026-02-26 13:44:57.42292
wake_attempts        | 4
last_provision_error |
gateway_id           | 0dfe28fc-4330-4c98-9f41-07f120ee8a31

-[ RECORD 2 ]--------+-------------------------------------
id                   | 5ba41e13-0b6e-4540-a388-a5c13843b864
name                 | server-gateway Gateway Agent
status               | updating
last_seen_at         | 2026-02-26 13:37:26.715917
wake_attempts        | 0
last_provision_error | [Errno 111] Connection refused
gateway_id           | 0dfe28fc-4330-4c98-9f41-07f120ee8a31

-[ RECORD 3 ]--------+-------------------------------------
id                   | b8f37f66-dae3-49de-81ba-13e80d4fa83c
name                 | Almanexia
status               | updating
last_seen_at         | 2026-02-26 13:52:37.693059
wake_attempts        | 5
last_provision_error | [Errno 111] Connection refused
gateway_id           | 0dfe28fc-4330-4c98-9f41-07f120ee8a31
```

### 2.2 Gateway DB Record (vor dem Fix)

```
id                     | 0dfe28fc-4330-4c98-9f41-07f120ee8a31
name                   | server-gateway
url                    | ws://172.20.0.1:18791        ← PROBLEM 1
token                  | fixed_gateway_auth_2026      ← PROBLEM 2
allow_insecure_tls     | f                            ← PROBLEM 3
```

### 2.3 Gateway Listen-Ports

```bash
$ ss -tlnp | grep 1879
LISTEN  127.0.0.1:18791   # ← nur loopback!
LISTEN  [::1]:18791
LISTEN  127.0.0.1:18793
LISTEN  [::1]:18793
```

### 2.4 Redis Queue State

```bash
$ redis-cli KEYS 'rq:*'
rq:worker:ec76c29f889d4414a8fe855406947bcd
rq:workers:default
rq:workers
# Keine rq:queue:* Keys → keine Jobs in der Queue
```

### 2.5 Worker Log

```
webhook-worker-1 | Worker ec76c29f...: cleaning registries for queue: default
# Sonst nichts — keine Lifecycle-Events, keine Job-Dequeues
```

### 2.6 Backend Log (nach erstem Fix-Versuch, vor Token-Fix)

```
ERROR app.services.openclaw.gateway_rpc gateway.rpc.call.transport_error
  method=health error_type=ValueError
```

### 2.7 Backend Log (nach Token-Fix, vor SSL-Fix)

```
last_provision_error | ssl=None is incompatible with a wss:// URI
```

### 2.8 Gateway openclaw.json (relevante Felder)

```json
{
  "port": 18791,
  "bind": "loopback",
  "auth": {
    "mode": "token",
    "token": "<REDACTED_32_CHAR_HEX>"
  },
  "allowedOrigins": [
    "http://127.0.0.1:8000",
    "http://91.99.172.36:18791",
    "http://localhost:8000",
    "https://agent.getvoidra.com",
    "https://mc.getvoidra.com"
  ]
}
```

### 2.9 Nginx Config (mc.getvoidra.com)

```nginx
location /api/ {
    proxy_pass http://127.0.0.1:8000/;   # Backend
}
location / {
    proxy_pass http://127.0.0.1:3010;    # Frontend
}
```

### 2.10 Nginx Config (agent.getvoidra.com)

```nginx
location / {
    proxy_pass http://127.0.0.1:18791;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    # ... SSL via Certbot
}
```

### 2.11 Connectivity vom Backend-Container

```bash
$ docker exec backend-1 curl -s -o /dev/null -w '%{http_code}' https://agent.getvoidra.com/
200

$ docker exec backend-1 getent hosts agent.getvoidra.com
91.99.172.36    agent.getvoidra.com
```

---

## 3) Root Causes

### RC-1: Gateway-URL nicht erreichbar aus Docker

| Detail | Wert |
|--------|------|
| DB gateway URL | `ws://172.20.0.1:18791` |
| Gateway bind | `127.0.0.1` (loopback only) |
| Docker bridge IP | `172.20.0.1` |
| Fehlermeldung | `[Errno 111] Connection refused` |

**Erklärung**: Der Gateway-Prozess bindet NUR auf `127.0.0.1`. Die Docker bridge IP `172.20.0.1` wird vom Host-Kernel rejected, weil der Gateway auf dieser Adresse nicht lauscht.

### RC-2: Token-Mismatch

| Detail | Wert |
|--------|------|
| DB token | `fixed_gateway_auth_2026` |
| Tatsächlicher Gateway-Token | `<REDACTED_32_CHAR_HEX>` (aus `openclaw.json`) |
| Gateway-Log Evidence | `reason=token_mismatch` |

**Erklärung**: Die Gateway-Registrierung in der MC-DB hatte einen alten/falschen Token.

### RC-3: WSS braucht SSL-Context

| Detail | Wert |
|--------|------|
| DB `allow_insecure_tls` | `false` |
| URL-Schema | `wss://` |
| Python websockets Verhalten | `ssl=None` bei `allow_insecure_tls=false` |
| Fehlermeldung | `ssl=None is incompatible with a wss:// URI` |

**Erklärung**: Die `websockets`-Library erfordert ein SSL-Objekt für `wss://`. Mit `allow_insecure_tls=false` übergibt der MC-Backend-Code `ssl=None`, was die Library ablehnt.

---

## 4) Fix Plan (minimal-invasiv)

| Schritt | Aktion | Risiko | Reversibel? |
|---------|--------|--------|-------------|
| 1 | Gateway-URL in DB ändern | Niedrig — nur DB-Update | ✅ Ja |
| 2 | Token in DB korrigieren | Niedrig — nur DB-Update | ✅ Ja |
| 3 | `allow_insecure_tls = true` setzen | Niedrig — nur DB-Update | ✅ Ja |
| 4 | Agent-States resetten | Niedrig — nur DB-Update | ✅ Ja |
| 5 | Backend + Worker restarten | Niedrig — Container-Restart | ✅ Automatisch |
| 6 | Template Sync triggern | Keine Änderung am Gateway | ✅ Idempotent |

**Nicht betroffen**: Gateway config, Volumes, Nginx, systemd Services, `.env`-Datei.

---

## 5) Execution

### 5.1 Backup erstellen

```bash
docker exec openclaw-mission-control-db-1 \
  psql -U postgres -d mission_control \
  -c "SELECT * FROM gateways;" > /tmp/mc_gateway_backup.txt

docker exec openclaw-mission-control-db-1 \
  psql -U postgres -d mission_control \
  -c "SELECT * FROM agents;" >> /tmp/mc_gateway_backup.txt
```

**Expected output**: Datei mit den aktuellen Records.

### 5.2 Fix 1: Gateway-URL

```sql
UPDATE gateways
SET url = 'wss://agent.getvoidra.com'
WHERE id = '0dfe28fc-4330-4c98-9f41-07f120ee8a31';
```

| Before | After |
|--------|-------|
| `ws://172.20.0.1:18791` | `wss://agent.getvoidra.com` |

**Expected output**: `UPDATE 1`

### 5.3 Fix 2: Gateway-Token

```sql
UPDATE gateways
SET token = '<ACTUAL_TOKEN_FROM_OPENCLAW_JSON>'
WHERE id = '0dfe28fc-4330-4c98-9f41-07f120ee8a31';
```

> ⚠️ Token niemals im Klartext loggen! Den Wert aus `~/.openclaw/openclaw.json` Feld `auth.token` entnehmen.

| Before | After |
|--------|-------|
| `fixed_gateway_auth_2026` | `<REDACTED>` (32-char hex aus openclaw.json) |

**Expected output**: `UPDATE 1`

### 5.4 Fix 3: allow_insecure_tls

```sql
UPDATE gateways
SET allow_insecure_tls = true
WHERE id = '0dfe28fc-4330-4c98-9f41-07f120ee8a31';
```

| Before | After |
|--------|-------|
| `false` | `true` |

**Expected output**: `UPDATE 1`

### 5.5 Reset Agent Lifecycle State

```sql
UPDATE agents
SET wake_attempts = 0,
    last_provision_error = NULL,
    checkin_deadline_at = NULL
WHERE gateway_id = '0dfe28fc-4330-4c98-9f41-07f120ee8a31';
```

**Expected output**: `UPDATE 3`

### 5.6 Restart Backend + Worker

```bash
cd /opt/openclaw/openclaw-mission-control
docker compose restart backend webhook-worker
sleep 5
curl -s http://127.0.0.1:8000/healthz
```

**Expected output**: `{"ok":true}`

### 5.7 Template Sync triggern

```bash
TOKEN=$(grep LOCAL_AUTH_TOKEN /opt/openclaw/openclaw-mission-control/.env | cut -d= -f2)
curl -s -w "\nHTTP:%{http_code}" \
  -X POST http://127.0.0.1:8000/api/v1/gateways/0dfe28fc-4330-4c98-9f41-07f120ee8a31/templates/sync \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

**Expected output**: JSON mit `gateway_id`, `include_main: true` + `HTTP:200`

---

## 6) Verification Checklist

### 6.1 API: Gateway RPC funktioniert

```bash
# Backend-Logs prüfen (keine gateway_rpc Errors mehr)
docker compose logs backend --since=5m --no-color 2>&1 | grep 'gateway_rpc'
```

**Expected**: Keine `ERROR` Zeilen, oder `gateway.rpc.call.ok`.

### 6.2 Redis: Lifecycle-Jobs vorhanden

```bash
docker exec openclaw-mission-control-redis-1 redis-cli KEYS '*'
```

**Expected**: `default:scheduled` Key vorhanden (enthält `agent_lifecycle_reconcile` Jobs).

```bash
docker exec openclaw-mission-control-redis-1 redis-cli \
  ZRANGEBYSCORE 'default:scheduled' '-inf' '+inf' WITHSCORES LIMIT 0 5
```

**Expected**: Einträge mit `task_type: agent_lifecycle_reconcile`.

### 6.3 Worker: Jobs werden verarbeitet

```bash
docker compose logs webhook-worker --since=5m --no-color 2>&1 | grep -v 'cleaning'
```

**Expected**: Lifecycle-Handler-Einträge (nicht nur "cleaning registries").

### 6.4 DB: Agents Status

```bash
docker exec openclaw-mission-control-db-1 psql -U postgres -d mission_control \
  -x -c "SELECT id, name, status, wake_attempts, last_provision_error, last_seen_at FROM agents;"
```

**Expected**: `last_provision_error` leer, `status` ändert sich von `updating` → `online`.

### 6.5 Gateway Logs: Provisioning-Aktivität

```bash
journalctl -u openclaw-gateway.service --since '5 minutes ago' --no-pager | \
  grep -iE 'provision|template|agent|wake|bootstrap|admin'
```

**Expected**: Agent model/canvas Einträge sichtbar.

### 6.6 API: Agent-Liste

```bash
TOKEN=$(grep LOCAL_AUTH_TOKEN /opt/openclaw/openclaw-mission-control/.env | cut -d= -f2)
curl -s http://127.0.0.1:8000/api/v1/agents \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
```

**Expected**: Alle 3 Agents mit `status: online` und aktuellem `last_seen_at`.

### 6.7 UI: Dashboard prüfen

Öffne `https://mc.getvoidra.com/agents` und verifiziere:
- Alle Agents zeigen **Online** Status
- **Last seen** ist aktuell (nicht mehr 10h+)

---

## 7) Rollback Plan

Falls die Änderungen unerwünschte Effekte haben:

```sql
-- Rollback Fix 1: URL zurücksetzen
UPDATE gateways
SET url = 'ws://172.20.0.1:18791'
WHERE id = '0dfe28fc-4330-4c98-9f41-07f120ee8a31';

-- Rollback Fix 2: Alten Token wiederherstellen
UPDATE gateways
SET token = 'fixed_gateway_auth_2026'
WHERE id = '0dfe28fc-4330-4c98-9f41-07f120ee8a31';

-- Rollback Fix 3: allow_insecure_tls zurücksetzen
UPDATE gateways
SET allow_insecure_tls = false
WHERE id = '0dfe28fc-4330-4c98-9f41-07f120ee8a31';
```

Dann: `docker compose restart backend webhook-worker`

> **Hinweis**: Der Rollback stellt den alten (kaputten) Zustand wieder her. Die Agents werden dann wieder UPDATING/OFFLINE.

---

## 8) Prevention

### 8.1 Konfig-Regeln

| Regel | Beschreibung |
|-------|-------------|
| **Gateway-URL** | Muss von **innerhalb Docker** erreichbar sein. Bei loopback-bound Gateway: Nginx-Proxy-URL verwenden (`wss://agent.getvoidra.com`) |
| **Gateway-Token** | Muss exakt dem Token in `~/.openclaw/openclaw.json` → `auth.token` entsprechen |
| **allow_insecure_tls** | Muss `true` sein wenn `wss://` über lokalen Reverse Proxy |
| **allowedOrigins** | Muss `https://mc.getvoidra.com` enthalten (in `openclaw.json`) |
| **NEXT_PUBLIC_API_URL** | Muss vom Browser erreichbar sein (korrekt: `https://mc.getvoidra.com/api`) |

### 8.2 Monitoring-Empfehlungen

```bash
# Cron-Check: Agent heartbeat Alter (alle 10 Minuten)
*/10 * * * * docker exec openclaw-mission-control-db-1 \
  psql -U postgres -d mission_control -t \
  -c "SELECT count(*) FROM agents WHERE last_seen_at < NOW() - INTERVAL '30 minutes';" \
  | xargs -I{} test {} -gt 0 && echo "ALERT: Agents stale" | logger -t mc-monitor

# Cron-Check: Worker alive
*/5 * * * * docker exec openclaw-mission-control-redis-1 \
  redis-cli SCARD rq:workers | xargs -I{} test {} -lt 1 && \
  echo "ALERT: No RQ workers" | logger -t mc-monitor
```

### 8.3 Annahmen

| Annahme | Prüfmethode |
|---------|-------------|
| Gateway hört weiterhin auf loopback | `ss -tlnp \| grep 18791` |
| Nginx Proxy bleibt stabil für WSS | `curl -s https://agent.getvoidra.com/ \| head -1` |
| Token ändert sich nicht nach Gateway-Update | `grep token ~/.openclaw/openclaw.json` nach jedem OpenClaw Update prüfen |
| Let's Encrypt Zertifikate werden erneuert | `certbot certificates` |

---

## 9) Appendix

### A. Komplettes Fix-SQL-Script

```sql
-- ===============================================
-- Mission Control Agents Fix — SQL Script
-- Datum: 2026-02-27
-- Server: root@91.99.172.36
-- ===============================================

-- BACKUP ERSTELLEN (vor Ausführung!)
-- docker exec openclaw-mission-control-db-1 pg_dump -U postgres mission_control > /tmp/mc_backup_YYYYMMDD.sql

-- Fix 1: Gateway URL (Docker-erreichbar via Nginx Proxy)
UPDATE gateways
SET url = 'wss://agent.getvoidra.com'
WHERE id = '0dfe28fc-4330-4c98-9f41-07f120ee8a31';

-- Fix 2: Gateway Token korrigieren
-- HINWEIS: Token aus ~/.openclaw/openclaw.json → auth.token entnehmen!
-- UPDATE gateways SET token = '<TOKEN_AUS_OPENCLAW_JSON>' WHERE id = '0dfe28fc-...';

-- Fix 3: SSL für WSS aktivieren
UPDATE gateways
SET allow_insecure_tls = true
WHERE id = '0dfe28fc-4330-4c98-9f41-07f120ee8a31';

-- Agent Lifecycle State zurücksetzen
UPDATE agents
SET wake_attempts = 0,
    last_provision_error = NULL,
    checkin_deadline_at = NULL
WHERE gateway_id = '0dfe28fc-4330-4c98-9f41-07f120ee8a31';

-- Verifikation
SELECT id, url, allow_insecure_tls FROM gateways;
SELECT id, name, status, wake_attempts, last_provision_error FROM agents;
```

### B. Curl Examples (Secrets redacted)

```bash
# Healthz Check
curl -s http://127.0.0.1:8000/healthz
# → {"ok":true}

# Agent-Liste abrufen
TOKEN="<LOCAL_AUTH_TOKEN>"
curl -s http://127.0.0.1:8000/api/v1/agents \
  -H "Authorization: Bearer $TOKEN"

# Template Sync triggern
curl -s -X POST \
  http://127.0.0.1:8000/api/v1/gateways/0dfe28fc-4330-4c98-9f41-07f120ee8a31/templates/sync \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"

# Gateway-Status prüfen
curl -s http://127.0.0.1:8000/api/v1/gateways/status \
  -H "Authorization: Bearer $TOKEN"

# Einzelnen Agent aktualisieren (löst ggf. Lifecycle aus)
curl -s -X PATCH \
  http://127.0.0.1:8000/api/v1/agents/<AGENT_ID> \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"<AGENT_NAME>"}'
```

### C. Relevante Dateipfade

| Pfad | Beschreibung |
|------|-------------|
| `/opt/openclaw/openclaw-mission-control/.env` | MC Stack Umgebungsvariablen |
| `/opt/openclaw/openclaw-mission-control/compose.yml` | Docker Compose Definition |
| `/home/agentadmin/.openclaw/openclaw.json` | Gateway-Hauptkonfiguration |
| `/etc/nginx/sites-available/mission-control` | Nginx Proxy für mc.getvoidra.com |
| `/etc/nginx/sites-available/openclaw` | Nginx Proxy für agent.getvoidra.com |
| `/etc/systemd/system/openclaw-gateway.service` | Gateway systemd Service |

### D. Container-Übersicht

| Container | Port (Host) | Funktion |
|-----------|------------|----------|
| `openclaw-mission-control-backend-1` | 8000 | FastAPI Backend |
| `openclaw-mission-control-frontend-1` | 3010 | Next.js UI |
| `openclaw-mission-control-webhook-worker-1` | — | RQ Worker (Lifecycle Jobs) |
| `openclaw-mission-control-db-1` | 5432 | PostgreSQL |
| `openclaw-mission-control-redis-1` | 6379 | Redis (Job Queue) |
