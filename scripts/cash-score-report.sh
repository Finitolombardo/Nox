#!/usr/bin/env bash
set -euo pipefail

HOUR_UTC=$(date -u +%H)
if [ "$HOUR_UTC" != "22" ]; then
  echo "HEARTBEAT_OK"
  exit 0
fi

CFG="/root/.openclaw/openclaw.json"
NOTION_KEY=$(jq -r '.skills.entries.notion.apiKey // .env.vars.NOTION_API_KEY // empty' "$CFG")
[ -n "$NOTION_KEY" ] || { echo "ALERT: Cash-Score Report failed (missing Notion key)"; exit 0; }

CAMP_DS="2bb09df6-e88e-802c-9f67-000b668970b8"
PITCH_DS="2bb09df6-e88e-8045-a613-000b941fc53e"
TMP_DIR=$(mktemp -d)

curl -sS -X POST "https://api.notion.com/v1/data_sources/$CAMP_DS/query" \
  -H "Authorization: Bearer $NOTION_KEY" -H "Notion-Version: 2025-09-03" -H "Content-Type: application/json" \
  --data '{"page_size":100}' > "$TMP_DIR/camp.json"

curl -sS -X POST "https://api.notion.com/v1/data_sources/$PITCH_DS/query" \
  -H "Authorization: Bearer $NOTION_KEY" -H "Notion-Version: 2025-09-03" -H "Content-Type: application/json" \
  --data '{"page_size":200}' > "$TMP_DIR/pitch.json"

python3 - "$TMP_DIR/camp.json" "$TMP_DIR/pitch.json" <<'PY'
import json,sys
camp=json.load(open(sys.argv[1]))
pitch=json.load(open(sys.argv[2]))

def title(props):
    for _,v in props.items():
        if v.get('type')=='title':
            return ''.join(t.get('plain_text','') for t in v.get('title',[]))
    return ''

def rt(props,k):
    v=props.get(k,{})
    return ''.join(t.get('plain_text','') for t in v.get('rich_text',[])) if v.get('type')=='rich_text' else ''

def num(props,k):
    v=props.get(k,{})
    return float(v.get('number') or 0) if v.get('type')=='number' else 0.0

if camp.get('object')=='error' or pitch.get('object')=='error':
    print('ALERT: Cash-Score Report failed (Notion query error).')
    sys.exit(0)

campaigns=[]
for c in camp.get('results',[]):
    pr=c['properties']
    campaigns.append({'name':title(pr),'id':rt(pr,'instantly Campaign ID')})

rows=[]
for p in pitch.get('results',[]):
    pr=p['properties']
    cid=rt(pr,'Campaign_ID')
    emails=num(pr,'EmailsSent')
    P=(num(pr,'PositiveReplyCount')/emails*100.0) if emails>0 else 0.0
    R=num(pr,'ReplyRate')
    O=num(pr,'OpenRate')
    S=(0.6*P)+(0.25*R)+(0.15*O)
    rows.append({'cid':cid,'score':S,'P':P,'R':R,'O':O})

lines=[]
for c in campaigns:
    rel=[r for r in rows if c['id'] and r['cid']==c['id']]
    if not rel:
        continue
    best=max(rel,key=lambda x:x['score'])
    lines.append(f"- {c['name']}: Cash-Score {best['score']:.2f} (P {best['P']:.2f} | R {best['R']:.2f} | O {best['O']:.2f})")

if not lines:
    print('ALERT: 22:00 Cash-Score Report: keine kampagnenbezogenen Score-Daten gefunden.')
else:
    print('22:00 Cash-Score Report\n' + '\n'.join(lines))
PY

rm -rf "$TMP_DIR"
