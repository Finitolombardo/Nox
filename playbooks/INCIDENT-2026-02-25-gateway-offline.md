# INCIDENT: Gateway wirkte offline / kam nicht zurück

- Date: 2026-02-25
- Severity: Major (Control UI Verbindungsabbrüche / Fehlwahrnehmung "offline")

## Symptom
- Control UI verlor Verbindung wiederholt; teilweise "origin not allowed", "token mismatch", "pairing required" und wiederholte Restart/Stop-Sequenzen.

## Timeline (UTC)
- 15:36:59–15:44:09: Wiederholt `Gateway failed to start: another gateway instance is already listening on ws://127.0.0.1:18791`.
- 16:32:25: `reason=origin not allowed` (Handshake abgelehnt).
- 16:33:37: `signal SIGINT received` + `received SIGINT; shutting down`.
- 16:55:57: `EACCES: permission denied, open '/home/agentadmin/.openclaw/workspace/SOUL.md'`.
- 17:07:35: `signal SIGTERM received` + `received SIGTERM; shutting down`.
- 17:07:44: `unauthorized: gateway token mismatch`.

## Root Cause(s)
1) Mehrere konkurrierende Gateway-Instanzen/Startversuche auf Port 18791 (Port bereits belegt).
2) UI-Origin/Auth-Drift (`origin not allowed`, später `token mismatch`) → wirkte wie "offline", obwohl Prozess lief.
3) User-/Config-Drift (`/root/.openclaw` vs `agentadmin` Kontext sichtbar in Logs) → inkonsistente Laufzeitpfade.
4) Dateiberechtigung defekt (`EACCES` auf workspace/SOUL.md) blockierte Schreib-/Agent-Operationen.
5) Manuelle Signale (`SIGINT`/`SIGTERM`) unterbrachen laufende Instanz.

## Fix (durchgeführt / abgeleitet)
- Single-instance disziplin: vor Start prüfen/stoppen (`openclaw gateway stop`, dann sauberer Start).
- Origin/Proxy Settings angleichen (`gateway.controlUi.allowedOrigins`, `gateway.trustedProxies`) und Gateway neu starten.
- Einheitlichen Benutzer erzwingen (agentadmin) und root-state vermeiden.
- Workspace-Permissions reparieren (owner/group, read/write für agentadmin).
- Token-Mismatch durch konsistente Dashboard-URL + Token neu synchronisieren.

## Prevention
- Neues Runbook: `PB-gateway-recovery-and-ui-access.md`.
- Keine parallelen manuellen Startschleifen; nur Service-gestützter Restart.
- Vor jedem Incident-Fix: Port/Prozess/User/Config-Pfad als Checkliste verifizieren.

## Evidence
- /tmp/openclaw/openclaw-2026-02-25.log#120 (`another gateway instance...`)
- /tmp/openclaw/openclaw-2026-02-25.log#150 (`origin not allowed`)
- /tmp/openclaw/openclaw-2026-02-25.log#181-182 (`SIGINT` shutdown)
- /tmp/openclaw/openclaw-2026-02-25.log#335 (`EACCES ... SOUL.md`)
- /tmp/openclaw/openclaw-2026-02-25.log#421-422 (`SIGTERM` shutdown)
- /tmp/openclaw-0/openclaw-2026-02-25.log#3179 (root config path), #3139 (`token mismatch`)
