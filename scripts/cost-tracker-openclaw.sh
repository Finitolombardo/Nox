#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-logs/cost-tracker}"
mkdir -p "$OUT_DIR"
TS="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
OUT_FILE="$OUT_DIR/$TS.json"

# Capture session status card and deep status for cost/usage telemetry
{
  echo "{"
  echo "  \"timestamp_utc\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"," 
  echo "  \"openclaw_status\": "
  openclaw status --deep --json 2>/dev/null || echo "{}"
  echo "}"
} > "$OUT_FILE"

echo "$OUT_FILE"
