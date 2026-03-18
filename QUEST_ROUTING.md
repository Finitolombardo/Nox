# Quest-Routing - AUTOMATISCH

## KRITISCHE REGEL
Bei Quest-Fragen IMMER diesen Pfad verwenden:

### Quest-Fragen erkennen
Wenn Frage enthält:
- "quest"
- "task"
- "offene aufgaben"
- "was haben wir"
- "welche aufgaben"

### DANN:
1. NIE workspace-Dateien lesen
2. NIE questboard/quests.json lesen
3. NIE DASHBOARD.md lesen
4. STATTDESSEN: MC-API aufrufen

### MC-API Aufruf
```bash
# Board-Liste
curl -s -H "Authorization: Bearer c4d3df3ad01f5e220c53f5eceee07e856c7e6ed140ad6dc825d720e0d223ae7b" \
  https://mc.getvoidra.com/api/v1/boards

# Tasks für Board
BOARD_ID="b1234567-1234-1234-1234-123456789012"
curl -s -H "Authorization: Bearer c4d3df3ad01f5e220c53f5eceee07e856c7e6ed140ad6dc825d720e0d223ae7b" \
  https://mc.getvoidra.com/api/v1/boards/$BOARD_ID/tasks
```

### Legacy-Dateien SIND ENTFERNT
- questboard/quests.json → .archive/quest-legacy/
- DASHBOARD.md → .archive/quest-legacy/

### Keine Ausnahmen
Quest-Daten gibt es NUR in der MC-API.
