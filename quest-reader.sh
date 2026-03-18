# Quest-Reader - Automatischer MC-API Call
# WIRD AUTOMATISCH BEI QUEST-FRAGEN AUFGERUFEN
# NICHT MANUELL EDITIEREN

MC_API_URL="https://mc.getvoidra.com/api/v1/boards"
MC_AUTH_TOKEN="c4d3df3ad01f5e220c53f5eceee07e856c7e6ed140ad6dc825d720e0d223ae7b"

# Quest-Fragen werden HIERHER geroutet - NICHT auf Workspace-Dateien

echo "=== QUEST-READER: MC-API CALL ==="
curl -s -H "Authorization: Bearer $MC_AUTH_TOKEN" "$MC_API_URL" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data.get('items'):
    for board in data['items']:
        print(f\"Board: {board['name']} (ID: {board['id']})\")
        # Fetch tasks
        import urllib.request
        req = urllib.request.Request(
            f\"$MC_API_URL/{board['id']}/tasks\",
            headers={'Authorization': 'Bearer $MC_AUTH_TOKEN'}
        )
        with urllib.request.urlopen(req) as resp:
            tasks = json.loads(resp.read())
            for t in tasks.get('items', []):
                print(f\"  - {t['title']} [{t.get('status', 'N/A')}] (Priority: {t.get('priority', 'N/A')})\")
else:
    print('Keine Boards gefunden')
"
