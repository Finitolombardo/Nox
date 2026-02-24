#!/usr/bin/env bash
set -euo pipefail
OUT_DIR="${1:-logs/cost-tracker}"
mkdir -p "$OUT_DIR"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
RAW="$(openclaw status --deep --json 2>/dev/null || echo '{}')"
SNAP=$(jq -cn --arg ts "$TS" --argjson raw "$RAW" '
  {
    timestamp_utc: $ts,
    total_tokens_sum: (($raw.sessions.recent // []) | map(.totalTokens // 0) | add // 0),
    input_tokens_sum: (($raw.sessions.recent // []) | map(.inputTokens // 0) | add // 0),
    output_tokens_sum: (($raw.sessions.recent // []) | map(.outputTokens // 0) | add // 0),
    cache_read_sum: (($raw.sessions.recent // []) | map(.cacheRead // 0) | add // 0),
    session_count: (($raw.sessions.recent // []) | length)
  }
')

echo "$SNAP" >> "$OUT_DIR/index.jsonl"
echo "$SNAP" > "$OUT_DIR/latest.json"
echo "$SNAP"
