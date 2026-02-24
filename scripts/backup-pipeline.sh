#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="/home/agentadmin/.openclaw/workspace"
STATE_JSON="$WORKSPACE/memory/infra-state.json"
ALERT_FILE="$WORKSPACE/memory/backup-alert.flag"
LOG_DIR="$WORKSPACE/logs/backups"
mkdir -p "$LOG_DIR"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
STAMP="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
LOG_FILE="$LOG_DIR/$STAMP.log"
ARCHIVE="$LOG_DIR/workspace-backup-$STAMP.tar.gz"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "[$TS] backup start"

on_fail() {
  local code=$?
  local msg="backup failed (code=$code) at $(date -u +%Y-%m-%dT%H:%M:%SZ); see $LOG_FILE"
  echo "$msg" > "$ALERT_FILE"
  if [ -f "$STATE_JSON" ]; then
    tmp=$(mktemp)
    jq --arg t "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg m "$msg" '.backup = (.backup // {}) | .backup.lastFailureUtc=$t | .backup.lastFailure=$m' "$STATE_JSON" > "$tmp" && mv "$tmp" "$STATE_JSON"
  fi
  exit $code
}
trap on_fail ERR

cd "$WORKSPACE"

# 1) GitHub backup (silent success)
git add -A
if ! git diff --cached --quiet; then
  git commit -m "Auto-backup snapshot $STAMP" || true
fi
git push origin main

echo "git push ok"

# 2) Google Drive backup (important folder: NOX_Backups)
# Build compressed workspace snapshot (exclude heavy/generated dirs)
tar --exclude='.git' --exclude='node_modules' --exclude='logs/backups' --exclude='logs/cost-tracker' \
    -czf "$ARCHIVE" .
echo "archive created: $ARCHIVE"

# Resolve/Create Drive target folder as agentadmin gog account
DRIVE_FOLDER_NAME="NOX_Backups"
DRIVE_FOLDER_ID=$(sudo -u agentadmin -H bash -lc 'export GOG_KEYRING_PASSWORD=openclaw; gog drive search "name = '\''NOX_Backups'\'' and mimeType = '\''application/vnd.google-apps.folder'\'' and trashed = false" --json --results-only --account admin@alphamindhub.com | jq -r ".[0].id // empty"')
if [ -z "$DRIVE_FOLDER_ID" ]; then
  DRIVE_FOLDER_ID=$(sudo -u agentadmin -H bash -lc 'export GOG_KEYRING_PASSWORD=openclaw; gog drive mkdir "NOX_Backups" --json --results-only --account admin@alphamindhub.com | jq -r ".id"')
fi

sudo -u agentadmin -H bash -lc "export GOG_KEYRING_PASSWORD=openclaw; gog drive upload '$ARCHIVE' --parent '$DRIVE_FOLDER_ID' --account admin@alphamindhub.com --json --results-only >/dev/null"
echo "drive upload ok (folder: $DRIVE_FOLDER_ID)"

# 3) Silent success bookkeeping
rm -f "$ALERT_FILE"
if [ -f "$STATE_JSON" ]; then
  tmp=$(mktemp)
  jq --arg t "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg a "$ARCHIVE" '.backup = (.backup // {}) | .backup.lastSuccessUtc=$t | .backup.lastArchive=$a | .backup.status="ok" | del(.backup.lastFailureUtc,.backup.lastFailure)' "$STATE_JSON" > "$tmp" && mv "$tmp" "$STATE_JSON"
fi

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] backup success"
