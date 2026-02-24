#!/usr/bin/env bash
set -euo pipefail
cd /home/agentadmin/.openclaw/workspace
cat <<'EOF'
INCLUDE:
- playbooks/
- memory/
- SOUL.md
- NOX_CHECKLIST.md
- HEARTBEAT.md
- scripts/

EXCLUDE:
- node_modules/
- logs/cost-tracker/*.json (nur aggregiert sichern)
- secrets/tokens in config dumps
EOF
