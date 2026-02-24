#!/bin/sh
set -eu

DB="/home/agentadmin/.openclaw/workspace/memory_system/memory.db"

TITLE=""
TAGS=""
TEXT=""
FILEPATH=""

# POSIX argument parsing
while [ $# -gt 0 ]; do
  case "$1" in
    --title) TITLE=${2:-}; shift 2 ;;
    --tags) TAGS=${2:-}; shift 2 ;;
    --text) TEXT=${2:-}; shift 2 ;;
    --file) FILEPATH=${2:-}; shift 2 ;;
    *) shift 1 ;;
  esac
done

if [ -n "$FILEPATH" ]; then
  TEXT="$(cat "$FILEPATH")"
fi

if [ -z "$TITLE" ]; then
  echo "ERROR: --title is required" >&2
  exit 1
fi
if [ -z "$TEXT" ]; then
  echo "ERROR: provide --text or --file" >&2
  exit 1
fi

# Escape single quotes for SQL string literals
esc_sql() {
  # doubles single quotes for SQLite
  printf "%s" "$1" | sed "s/'/''/g"
}

ESC_TITLE="$(esc_sql "$TITLE")"
ESC_TAGS="$(esc_sql "$TAGS")"

# Store note content as base64 (avoids SQL quoting issues completely)
CONTENT_B64="$(printf "%s" "$TEXT" | base64 | tr -d '\n')"

NOTE_ID="$(sqlite3 "$DB" <<SQL
INSERT INTO notes(title, content, tags, created_at)
VALUES ('$ESC_TITLE', '$CONTENT_B64', '$ESC_TAGS', datetime('now'));
SELECT last_insert_rowid();
SQL
)"

# Chunk the raw text into fixed-size pieces (simple + dash-safe)
TMP="$(mktemp)"
printf "%s" "$TEXT" > "$TMP"

CHUNK_SIZE=1000
SIZE="$(wc -c < "$TMP" | tr -d ' ')"
POS=0
IDX=0

while [ "$POS" -lt "$SIZE" ]; do
  CHUNK="$(dd if="$TMP" bs=1 skip="$POS" count="$CHUNK_SIZE" 2>/dev/null || true)"
  POS=$((POS + CHUNK_SIZE))

  # skip empty chunk
  [ -z "$CHUNK" ] && continue

  CHUNK_B64="$(printf "%s" "$CHUNK" | base64 | tr -d '\n')"

  sqlite3 "$DB" <<SQL
INSERT INTO chunks(note_id, chunk_index, chunk_text, created_at)
VALUES ($NOTE_ID, $IDX, '$CHUNK_B64', datetime('now'));
SQL

  IDX=$((IDX + 1))
done

rm -f "$TMP"

echo "OK note_id=$NOTE_ID chunks=$IDX"
