# Playbook: Modell-Zuweisung

## Ziel
Primäres Modell pro Agent/Workspace in OpenClaw sauber zuweisen, Config validieren und Gateway neu laden.

## Geltende Zuweisung (Stand 2026-02-24)
- `main` (Workspace: `/home/agentadmin/.openclaw/workspace`)
  - `model.primary`: `openrouter/google/gemini-2.5-flash-lite`
- `coder` (Workspace: `/home/agentadmin/.openclaw/workspace-coder`)
  - `model.primary`: `openai-codex/gpt-5.3-codex`

## Vorgehen
1. Config-Datei öffnen: `~/.openclaw/openclaw.json`
2. `agents.list` mit agent-spezifischen Overrides setzen (`main`, `coder`).
3. JSON validieren (hartes Gate):
   - `python3 -m json.tool ~/.openclaw/openclaw.json >/dev/null`
4. Gateway-Reload ausführen:
   - `openclaw gateway restart`
5. Runtime verifizieren:
   - `openclaw gateway status`
   - `openclaw status`

## Wichtige Hinweise
- Bestehende Sessions laufen ggf. mit ihrem bereits gesetzten Modell weiter.
- Die neue Modellzuweisung greift zuverlässig bei neuen Sessions bzw. bei Agent-Routing auf den jeweiligen Agent.
- Änderungen immer erst nach erfolgreicher JSON-Validierung anwenden.
