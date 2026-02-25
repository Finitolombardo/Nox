# PB-gateway-recovery-and-ui-access.md

## Zweck
Runbook für "Gateway wirkt offline / UI kommt nicht zurück" inkl. sicherem Restart und Drift-Prävention.

## 1) Health Checks (read-only)
```bash
# Prozess + Port
ps -ef | grep -E 'openclaw-gateway|openclaw .* gateway' | grep -v grep
ss -ltnp | grep 18791 || true

# OpenClaw Gesamtstatus
openclaw status

# Relevante Logs
tail -n 120 /home/agentadmin/openclaw-gateway.log
tail -n 120 /tmp/openclaw/openclaw-$(date -u +%F).log 2>/dev/null || true
tail -n 120 /tmp/openclaw-0/openclaw-$(date -u +%F).log 2>/dev/null || true
```

## 2) Safe Restart Procedure (single instance)
```bash
# 1) Graceful stop (service-managed)
openclaw gateway stop

# 2) Verifizieren: nichts lauscht mehr auf 18791
ss -ltnp | grep 18791 || echo "port free"

# 3) Start
openclaw gateway start

# 4) Verify
openclaw gateway status
openclaw status
ss -ltnp | grep 18791
```

### Wenn Port weiter belegt ist
```bash
# PID identifizieren und nur den verwaisten Prozess beenden
ss -ltnp | grep 18791
kill <PID>
# dann erneut openclaw gateway start
```

## 3) allowedOrigins + trustedProxies
- Setze `gateway.controlUi.allowedOrigins` auf die tatsächlich genutzte(n) UI-Origin(s).
- Setze `gateway.trustedProxies` wenn Reverse Proxy Header liefert.
- Nach Änderung: Gateway neu starten.

Prüfen in Logs:
- `origin not allowed` → allowedOrigins fehlt/falsch
- `Proxy headers detected from untrusted address` → trustedProxies fehlt

## 4) Permissions Repair (workspace)
```bash
# Ownership auf agentadmin korrigieren (keine Secrets ausgeben)
sudo chown -R agentadmin:agentadmin /home/agentadmin/.openclaw/workspace

# Sinnvolle Rechte (Dateien 644, Verzeichnisse 755)
find /home/agentadmin/.openclaw/workspace -type d -exec chmod 755 {} \;
find /home/agentadmin/.openclaw/workspace -type f -exec chmod 644 {} \;
```

## 5) Single Source of Truth (no root .openclaw drift)
- Gateway dauerhaft als **agentadmin** betreiben.
- Keine gemischten Runtime-Pfade zwischen `/root/.openclaw` und `/home/agentadmin/.openclaw`.
- Keine parallelen manuellen Starts in verschiedenen Shells/Users.

## 6) Verification Checklist (must pass)
- [ ] Nur **ein** Listener auf `127.0.0.1:18791`.
- [ ] `openclaw status` zeigt Gateway reachable + service running.
- [ ] Keine neuen `origin not allowed` Fehler im Log.
- [ ] Keine neuen `token mismatch` Fehler im Log.
- [ ] Keine `EACCES` Fehler auf Workspace-Dateien.
- [ ] UI kann verbinden und bleibt stabil (>2 min ohne reconnect loop).

## 7) Known failure signatures
- `another gateway instance is already listening` → Doppelstart/Port-Konflikt
- `origin not allowed` → allowedOrigins-Konfiguration fehlt/falsch
- `unauthorized: gateway token mismatch` → falscher Token im UI
- `EACCES ... workspace/*.md` → Datei-Besitz/Rechte fehlerhaft
- `SIGINT/SIGTERM` kurz nach Start → manuelles/externes Stop-Signal
