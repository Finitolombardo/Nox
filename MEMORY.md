# MEMORY

## Regeln
- Memory nur bei Bedarf laden
- Stable und Telemetry trennen
- Keine Secrets speichern

## Mission Control Truth
- Aktive Runtime-Agents: Archon, Forge, Archivarius, Waechter.
- Diese Workspaces sind die Wahrheit fuer agentenspezifische Core-Dateien.
- Mission Control nutzt OpenClaw fuer Status/Core, MCP fuer Memory und das Dashboard fuer Quests/Runs/Artifacts.
- Playbooks kommen aus MCP/Workspace; Dashboard ist dafuer Mirror und sichtbarer Verwaltungs-Feed.
