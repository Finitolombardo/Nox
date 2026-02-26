# Playbook: Agenten-Workspace erstellen

## Ziel
Einen neuen Agenten in OpenClaw anlegen, eigenes Workspace-Verzeichnis zuweisen, Modell setzen und Änderung live im UI verfügbar machen.

## Technischer Prozess (verifiziert)

### 1) Konfigurationsdatei
- Datei: `~/.openclaw/openclaw.json`
- In diesem System aufgelöst zu: `/root/.openclaw/openclaw.json`

### 2) JSON-Struktur unter `agents.list`
Wenn `agents.list` nicht existiert, als Array anlegen. Danach Agent-Eintrag ergänzen:

```json
{
  "agents": {
    "list": [
      {
        "id": "main",
        "name": "Main",
        "default": true,
        "workspace": "/home/agentadmin/.openclaw/workspace",
        "model": "openai-codex/gpt-5.3-codex"
      },
      {
        "id": "coder",
        "name": "Coder",
        "workspace": "/home/agentadmin/.openclaw/workspace-coder",
        "model": "openai-codex/gpt-5.3-codex"
      }
    ]
  }
}
```

### 3) Workspace-Verzeichnis anlegen
```bash
mkdir -p /home/agentadmin/.openclaw/workspace-coder
```

### 4) Reload/Restart
OpenClaw unterstützt Hot-Reload; alternativ explizit Service-Neustart:

```bash
openclaw gateway restart
```

### 5) Verifikation
```bash
openclaw gateway status
openclaw status --deep
```
Erwartung: `Agents: 2` und Agent `coder` sichtbar.

## Hinweise
- Bei produktiven Änderungen vorher Backup von `openclaw.json` erstellen.
- Modell-IDs exakt als `provider/model` schreiben.
- Bei UI-Cache einmal Browser hard refresh ausführen.
