# Playbook: Notion Quest (Task) anlegen

## 🎯 Ziel
Fehlerfreies, sofortiges Anlegen von Quests/Aufgaben in der Notion-Datenbank beim ersten Versuch.

## ⚠️ Bekannte Fehlerquellen (Lessons Learned)
Aus vergangenen Fehlversuchen beim Anlegen von Quests haben sich folgende kritische Punkte ergeben, die zwingend beachtet werden müssen:

1. **Strikte Schema-Einhaltung (Property Types):**
   - **Titel:** Muss als `title`-Array mit `text.content` übergeben werden, nicht als normaler String.
   - **Status/Selects:** Muss exakt dem Wording im Notion-Setup entsprechen (z.B. "Geplant", "In Arbeit", nicht "To Do" wenn es nicht existiert). Case-sensitive!
   - **Datum:** ISO 8601 Format (`YYYY-MM-DD`) nutzen.

2. **Parent-Verknüpfung:**
   - Jede neue Seite MUSS ein `parent`-Objekt haben.
   - Bei Quests ist das `parent` meist die `database_id` der Quest-Datenbank, NICHT der Workspace.

3. **Inhalts-Blöcke (Children):**
   - Wenn Details in die Quest geschrieben werden, müssen diese als Array von `children`-Blöcken übergeben werden (z.B. `paragraph`, `heading_2`).

## 🛠 Standard-Workflow (Der "Richtig-beim-ersten-Mal"-Pfad)

1. **ID-Check:**
   - Sichere die exakte `database_id` der Quest-Datenbank (via `notion_db_map` oder direkter Abfrage).
2. **Payload-Aufbau (JSON-Struktur strikt einhalten):**
   ```json
   {
     "parent": { "database_id": "<ID_HIER>" },
     "properties": {
       "Name": { "title": [ { "text": { "content": "Quest-Titel" } } ] },
       "Status": { "status": { "name": "Geplant" } }
     }
   }
   ```
3. **API Call absenden:**
   - Ausführung des API-Calls oder Aufruf des entsprechenden Agent-Skills.
4. **Validierung:**
   - Prüfen, ob eine `id` in der Response zurückkommt. Wenn ja -> Success loggen. Wenn 400er Fehler -> Schema gegen die Notion-Datenbank-Properties abgleichen.

## 🚀 Fazit
Niemals raten, wie das Schema aussieht. Wenn unsicher: Einmal die Properties der DB abrufen (`/v1/databases/{id}`), dann Payload bauen.
