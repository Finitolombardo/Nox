#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$BASE_DIR"

WINDOW_MIN="${1:-60}"
COST_DIR="logs/cost-tracker"
mkdir -p "$COST_DIR"

# 1) New snapshot
SNAP_JSON="$(./scripts/cost-snapshot.sh "$COST_DIR")"
NOW_EPOCH=$(date -u +%s)
CUTOFF=$((NOW_EPOCH - WINDOW_MIN*60))

# 2) Cost growth proxy (tokens in last 60m)
if [ ! -f "$COST_DIR/index.jsonl" ]; then
  echo "HEARTBEAT_OK"
  exit 0
fi

WINDOW_JSON=$(jq -cs --argjson cutoff "$CUTOFF" '[.[] | select((.timestamp_utc | fromdateiso8601) >= $cutoff)]' "$COST_DIR/index.jsonl")
COUNT=$(echo "$WINDOW_JSON" | jq 'length')
if [ "$COUNT" -lt 2 ]; then
  echo "HEARTBEAT_OK"
  exit 0
fi

BASE_TOKENS=$(echo "$WINDOW_JSON" | jq 'first.total_tokens_sum // 0')
LATEST_TOKENS=$(echo "$WINDOW_JSON" | jq 'last.total_tokens_sum // 0')
DELTA=$((LATEST_TOKENS - BASE_TOKENS))

# 3) Strategic progress proxy (Notion task moved to Done in window)
CFG="/root/.openclaw/openclaw.json"
NOTION_KEY=$(jq -r '.skills.entries.notion.apiKey // .env.vars.NOTION_API_KEY // empty' "$CFG")
# Prefer explicit DB from config, fallback to Quests data source used in this workspace
DB_ID=$(jq -r '.env.vars.NOTION_DATABASE_ID // empty' "$CFG")
if [ -z "$DB_ID" ]; then
  DB_ID="18309df6-e88e-808f-a5fe-000b310df88b"
fi
DONE_COUNT=0

if [ -n "$NOTION_KEY" ] && [ -n "$DB_ID" ]; then
  RESP=$(curl -sS -X POST "https://api.notion.com/v1/data_sources/$DB_ID/query" \
    -H "Authorization: Bearer $NOTION_KEY" \
    -H "Notion-Version: 2025-09-03" \
    -H "Content-Type: application/json" \
    --data '{"page_size":100}' || true)

  # Null-safe JSON handling: Notion errors or empty payloads must not crash heartbeat
  DONE_COUNT=$(echo "$RESP" | jq -r --argjson cutoff "$CUTOFF" '
    if (.object? == "error") then 0
    else
      [(.results // [])[]
        | select((.properties["Status"].status.name // "") == "Erledigt")
        | select(
            ((.properties["Erledigt am"].date.start? // "1970-01-01T00:00:00Z") | fromdateiso8601? // 0) >= $cutoff
            or
            ((.last_edited_time // "1970-01-01T00:00:00Z") | fromdateiso8601? // 0) >= $cutoff
          )
      ] | length
    end
  ' 2>/dev/null || echo 0)
fi

if [ "$DELTA" -gt 0 ] && [ "$DONE_COUNT" -eq 0 ]; then
  echo "ALERT: Verzettelung erkannt — Token/Cost-Proxy stieg um +$DELTA in ${WINDOW_MIN}m, aber 0 strategische Fortschritte (Notion Done)."
else
  echo "HEARTBEAT_OK"
fi
