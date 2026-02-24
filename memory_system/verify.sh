#!/bin/sh
set -eu

DB="/home/agentadmin/.openclaw/workspace/memory_system/memory.db"
ADD="/home/agentadmin/.openclaw/workspace/memory_system/add_note.sh"
RET="/home/agentadmin/.openclaw/workspace/memory_system/retrieve.sh"

echo "=== schema ==="
sqlite3 "$DB" ".schema" | grep -q "CREATE TABLE notes" || { echo "FAIL: notes table missing"; exit 1; }
sqlite3 "$DB" ".schema" | grep -q "CREATE TABLE chunks" || { echo "FAIL: chunks table missing"; exit 1; }

echo "=== cleanup old sample ==="
sqlite3 "$DB" "DELETE FROM chunks WHERE note_id IN (SELECT id FROM notes WHERE title='Sample Title');"
sqlite3 "$DB" "DELETE FROM notes WHERE title='Sample Title';"

echo "=== add sample note ==="
OUT_ADD="$("$ADD" --title "Sample Title" --tags "tag1,tag2" --text "This is a sample note about telegram setup and cron jobs. Rate limit 429 timeout gateway closed invalid spec.")"
echo "$OUT_ADD"
echo "$OUT_ADD" | grep -q "OK note_id=" || { echo "FAIL: add_note failed"; exit 1; }

echo "=== retrieve ==="
OUT_RET="$("$RET" --q "telegram cron" --k 5 --budget_chars 3500 || true)"
printf "%s\n" "$OUT_RET"
printf "%s\n" "$OUT_RET" | grep -q "\[#1\]" || { echo "FAIL: retrieve returned no results"; exit 1; }

echo "PASS"
