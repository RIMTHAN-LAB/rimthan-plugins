#!/bin/bash

# Claude CLAUDE.md Auto-Update Script
# Called from post-commit hook when user approves background updates
# Resumes the analysis session with edit permissions

set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/platform.sh"
source "$SCRIPT_DIR/lib/config.sh"

SESSION_ID="$1"

if [ -z "$SESSION_ID" ]; then
  echo "Error: Session ID required"
  echo "Usage: $0 <session-id>"
  exit 1
fi

# Get logs directory from config
LOGS_DIR=$(get_logs_dir)
mkdir -p "$LOGS_DIR"

# Output file for logging
OUTPUT_FILE="${LOGS_DIR}/claude_update_${SESSION_ID}.json"

echo "Starting CLAUDE.md update in background..."
echo "Session ID: $SESSION_ID"
echo "Output log: $OUTPUT_FILE"

# Resume Claude session with edit permissions
TEMP_OUTPUT=$(mktemp)
claude -p \
  --resume "$SESSION_ID" \
  --tools "Edit,Write,Read" \
  --permission-mode bypassPermissions \
  --output-format json \
  --max-turns 20 \
  "Based on our previous analysis, please update the CLAUDE.md files now. Make all necessary edits directly to keep documentation in sync with the code changes we identified." \
  2>/dev/null > "$TEMP_OUTPUT"

# Pretty-print JSON to final output file
python3 -c "import sys, json; print(json.dumps(json.load(open('$TEMP_OUTPUT')), indent=2))" > "$OUTPUT_FILE" 2>/dev/null || cp "$TEMP_OUTPUT" "$OUTPUT_FILE"
rm -f "$TEMP_OUTPUT"

# Check if successful
if grep -q '"subtype":"success"' "$OUTPUT_FILE"; then
  # Success notification (cross-platform)
  send_notification "Claude Code Update" "CLAUDE.md files updated successfully! Review changes with: git diff"

  # Log success
  echo "✅ Update completed successfully"
  echo "Review changes: git diff"
  echo "Full log: $OUTPUT_FILE"

  exit 0
else
  # Failure notification (cross-platform)
  send_notification "Claude Code Update" "Update encountered issues. Check log for details."

  # Log failure
  echo "❌ Update failed or had issues"
  echo "Check log: $OUTPUT_FILE"

  # Extract error if available
  if grep -q '"subtype":"error"' "$OUTPUT_FILE"; then
    ERROR_MSG=$(grep -o '"message":"[^"]*"' "$OUTPUT_FILE" | head -1 | cut -d'"' -f4)
    echo "Error: $ERROR_MSG"
  fi

  exit 1
fi
