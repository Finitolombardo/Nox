#!/bin/sh
set -eu

INPUT=""
TITLE=""
TAGS=""

while [ $# -gt 0 ]; do
  case "$1" in
    --text) INPUT=${2:-}; shift 2 ;;
    --title) TITLE=${2:-}; shift 2 ;;
    --tags) TAGS=${2:-}; shift 2 ;;
    *) shift 1 ;;
  esac
done

if [ -z "$INPUT" ]; then
  echo "status=ERROR"
  echo "message=--text is required"
  exit 0
fi

case "$INPUT" in
  "MERK DIR:"*)
    BODY="$(printf "%s" "$INPUT" | sed 's/^MERK DIR:[[:space:]]*//')"
    [ -z "$BODY" ] && BODY="(empty)"
    [ -z "$TITLE" ] && TITLE="User Memory"
    [ -z "$TAGS" ] && TAGS="user_memory"

    OUT="$(/home/agentadmin/.openclaw/workspace/memory_system/add_note.sh \
      --title "$TITLE" --tags "$TAGS" --text "$BODY" 2>&1 || true)"

    echo "status=OK"
    echo "add_note_output<<EOF"
    printf "%s\n" "$OUT"
    echo "EOF"
    exit 0
    ;;
  *)
    echo "status=BLOCKED"
    echo "message=Not saved. Missing explicit trigger prefix: MERK DIR:"
    echo "suggestion=AUTO-MEMO VORSCHLAG: If you want to store this, resend starting with MERK DIR:"
    exit 0
    ;;
esac
