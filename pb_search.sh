#!/bin/sh
set -eu
Q="${1:-}"
if [ -z "$Q" ]; then
  echo "usage: pb_search.sh <query>" >&2
  exit 2
fi
grep -RIn --line-number --color=never "$Q" /home/agentadmin/.openclaw/workspace/playbooks | head -n 100
