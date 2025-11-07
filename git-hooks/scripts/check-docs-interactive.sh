#!/bin/bash

# Interactive version - Opens Claude Code with full context
# Use this when you want to chat with Claude about doc updates

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/detect-env.sh"

COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_MSG=$(git log -1 --pretty=%B)

# Detect changed stacks and build file pattern
stacks=$(detect_changed_stacks)
extensions=""
for stack in $stacks; do
    ext=$(get_extensions "$stack")
    if [ -n "$ext" ]; then
        extensions="$extensions,$ext"
    fi
done
extensions=$(echo "$extensions" | sed 's/^,//')

# Get changed files matching detected extensions
if [ -n "$extensions" ]; then
    CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD | grep -E "\.(${extensions//,/|})$")
else
    CHANGED_FILES=""
fi

if [ -z "$CHANGED_FILES" ]; then
  echo "No code files changed in last commit."
  exit 0
fi

# Dynamically discover all CLAUDE.md files using detected exclude paths
exclude_paths=$(get_all_exclude_paths)
find_excludes=""
for path in $exclude_paths; do
    find_excludes="$find_excludes -not -path '*/$path/*'"
done

CLAUDE_MD_FILES=$(eval "find . -name 'CLAUDE.md' $find_excludes" | sort | sed 's/^/   - /')

# Create context file
cat > /tmp/claude-doc-context.md <<EOF
# Documentation Check for Commit $COMMIT_HASH

## Commit Message
$COMMIT_MSG

## Changed Files
$(echo "$CHANGED_FILES" | sed 's/^/- /')

## Instructions
I've just committed changes to the files above. Please:

1. Run \`git show HEAD\` to see the full diff
2. Analyze which CLAUDE.md files might need updating (auto-discovered):
$CLAUDE_MD_FILES

3. For each file that needs updates:
   - Read the current CLAUDE.md
   - Propose specific changes
   - Make updates if I approve

Let me know what you find!
EOF

echo "Opening Claude Code with commit context..."

# Start Claude Code interactively with the context
claude "$(cat /tmp/claude-doc-context.md)"

# Clean up
rm /tmp/claude-doc-context.md
