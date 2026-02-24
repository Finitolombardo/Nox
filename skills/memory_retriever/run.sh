#!/bin/sh
set -eu

QUERY=""
PROOF=0

# POSIX arg parsing (NO [[ ]])
while [ $# -gt 0 ]; do
  case "$1" in
    --q)
      QUERY=${2:-}
      shift 2
      ;;
    --proof)
      PROOF=1
      shift 1
      ;;
    *)
      shift 1
      ;;
  esac
done

if [ -z "$QUERY" ]; then
  echo "ERROR: --q is required" >&2
  # Still exit 0 per requirement, but return structured output
  echo "retrieval_status=ERROR"
  echo "retrieved_memory="
  echo "instruction_to_model=You MUST answer using retrieved_memory. If NO_MATCH, do not claim memory."
  exit 0
fi

CMD="/home/agentadmin/.openclaw/workspace/memory_system/retrieve.sh --q \"$QUERY\" --k 8 --budget_chars 3500"
OUTPUT="$(/home/agentadmin/.openclaw/workspace/memory_system/retrieve.sh --q "$QUERY" --k 8 --budget_chars 3500 2>&1 || true)"

if printf "%s" "$OUTPUT" | grep -q "^NO_MATCH"; then
  STATUS="NO_MATCH"
else
  STATUS="OK"
fi

# Structured output (INI-style, robust in shell)
echo "retrieval_status=$STATUS"
echo "retrieved_memory<<EOF"
printf "%s\n" "$OUTPUT"
echo "EOF"
echo "instruction_to_model=You MUST answer using retrieved_memory. If NO_MATCH, do not claim memory."

if [ "$PROOF" -eq 1 ]; then
  echo "proof_executed_command<<EOF"
  printf "%s\n" "$CMD"
  echo "EOF"
  echo "proof_first_30_lines<<EOF"
  printf "%s\n" "$OUTPUT" | sed -n "1,30p"
  echo "EOF"
fi

exit 0
