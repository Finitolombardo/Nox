# Quest Source of Truth - OPERATIV

> Letzte Aktualisierung: 2026-03-17
> Status: PRODUKTIV

## source of Truth

**Alle operativen Quests/Boards kommen NUR von:**
```
https://mc.getvoidra.com/api/v1/boards
```

**Dashboard:**
```
https://mc.getvoidra.com/tasks
```

## Legacy-Dateien (NICHT mehr nutzen!)

| Datei | Status | Grund |
|-------|--------|-------|
| `workspace/questboard/quests.json` | **LEGACY/TEST** | Veraltet, nicht mehr aktiv |
| `workspace/DASHBOARD.md` | **LEGACY** | Nur Dokumentation, keine operativen Daten |
| `workspace/memory/agent-quests.json` | **LEGACY** | Nicht befüllt, Playbook-Referenz nur |
| `workspace/questboard/server.py` | **LEGACY/TEST** | Python-Server für Test, nicht produktiv |

## Agent-Pfad (PRODUKTIV)

Bei Fragen nach "Quests" oder "Boards":

1. **NUR** `https://mc.getvoidra.com/api/v1/boards` abfragen
2. Response parsen: `items[]` enthält Boards
3. Board-Felder: `name`, `board_type`, `status`, `description`

**Beispiel-API-Call:**
```bash
curl -s "https://mc.getvoidra.com/api/v1/boards" | jq '.items[] | {name, board_type}'
```

## Was NIE mehr tun

- `questboard/quests.json` lesen
- `DASHBOARD.md` als Datenquelle nutzen
- `memory/agent-quests.json` abfragen
- Andere lokale Dateien als Quest-Daten interpretieren
