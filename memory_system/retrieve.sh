#!/bin/sh
set -eu

DB="/home/agentadmin/.openclaw/workspace/memory_system/memory.db"

QUERY=""
K=8
BUDGET_CHARS=3500

while [ $# -gt 0 ]; do
  case "$1" in
    --q) QUERY=${2:-}; shift 2 ;;
    --k) K=${2:-8}; shift 2 ;;
    --budget_chars) BUDGET_CHARS=${2:-3500}; shift 2 ;;
    *) shift 1 ;;
  esac
done

if [ -z "$QUERY" ]; then
  echo "ERROR: --q is required" >&2
  exit 1
fi

# normalize + tokenize (drop <3 chars)
QLOW="$(printf "%s" "$QUERY" | tr '[:upper:]' '[:lower:]')"
TERMS="$(printf "%s" "$QLOW" | tr -cs 'a-z0-9' ' ' | awk '{for(i=1;i<=NF;i++) if(length($i)>=3) print $i}' | sort -u)"

if [ -z "$TERMS" ]; then
  echo "NO_MATCH"
  exit 0
fi

# Pull candidate chunks (simple prefilter: any term match via LIKE)
# We store chunk_text base64, so we can't LIKE it; we must decode.
# Pragmatic approach: decode all chunks, score in shell. Works for small DBs.
# (Later we can add a plaintext column for search.)
ROWS="$(sqlite3 "$DB" "SELECT c.note_id, c.chunk_index, c.chunk_text, n.title, n.tags FROM chunks c JOIN notes n ON n.id=c.note_id;")"

if [ -z "$ROWS" ]; then
  echo "NO_MATCH"
  exit 0
fi

# Score chunks
# Output lines: score|title|tags|note_id|chunk_index|snippet
SCORED="$(printf "%s\n" "$ROWS" | awk -F'|' '{print}' | while IFS='|' read -r NOTE_ID CHUNK_INDEX CHUNK_B64 TITLE TAGS; do
  TEXT="$(printf "%s" "$CHUNK_B64" | base64 -d 2>/dev/null || true)"
  [ -z "$TEXT" ] && continue
  TLOW="$(printf "%s" "$TEXT" | tr '[:upper:]' '[:lower:]')"

  SCORE=0
  for term in $TERMS; do
    # count occurrences
    C=$(printf "%s" "$TLOW" | awk -v t="$term" 'BEGIN{c=0} { while (match($0,t)) {c++; $0=substr($0,RSTART+RLENGTH)} } END{print c}')
    SCORE=$((SCORE + C))
  done

  [ "$SCORE" -le 0 ] && continue

  # short snippet
  SNIP="$(printf "%s" "$TEXT" | tr '\n' ' ' | awk '{print substr($0,1,220)}')"
  printf "%d|%s|%s|%s|%s|%s\n" "$SCORE" "$TITLE" "$TAGS" "$NOTE_ID" "$CHUNK_INDEX" "$SNIP"
done)"

if [ -z "$SCORED" ]; then
  echo "NO_MATCH"
  exit 0
fi

# Sort by score desc, take top K, enforce budget
OUT=""
TOTAL=0
I=1

printf "%s\n" "$SCORED" | sort -t'|' -k1,1nr | head -n "$K" | while IFS='|' read -r SCORE TITLE TAGS NOTE_ID CHUNK_INDEX SNIP; do
  BLOCK=$(printf "[#%d] score=%s | %s | %s | note_id=%s | chunk=%s\n%s\n---\n" "$I" "$SCORE" "$TITLE" "$TAGS" "$NOTE_ID" "$CHUNK_INDEX" "$SNIP")
  LEN=$(printf "%s" "$BLOCK" | wc -c | tr -d ' ')
  if [ $((TOTAL + LEN)) -gt "$BUDGET_CHARS" ]; then
    exit 0
  fi
  TOTAL=$((TOTAL + LEN))
  I=$((I + 1))
  printf "%s" "$BLOCK"
done
