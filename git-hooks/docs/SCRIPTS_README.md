# Git Hook Scripts

## Automated Documentation Checks

This directory contains scripts for maintaining CLAUDE.md documentation files.

---

## Scripts

### 1. `post-commit` (Auto Hook)

**Location**: `.husky/post-commit`
**Runs**: Automatically after every commit
**Mode**: Headless (Claude CLI with `-p` flag)

**What it does:**

- Detects code changes in commit
- Runs Claude CLI in headless mode to analyze impact
- Outputs recommendations for CLAUDE.md updates
- Non-blocking (you can continue working)

**Skip the check:**
Add `[skip-docs]` or `[docs-skip]` to your commit message:

```bash
git commit -m "fix typo [skip-docs]"
```

**Example output:**

```
📚 Analyzing commit for documentation impact...
⚠️  Documentation update recommended!

File: /src/app/hooks/CLAUDE.md
Reason: New hook useDebounce added
Changes: Add to "File Organization" and "Common Tasks" sections

💡 Review the suggestions and update CLAUDE.md files if needed.
```

---

### 2. `claude-update-docs.sh` (Background Update) **NEW!**

**Location**: `.husky/scripts/claude-update-docs.sh`
**Runs**: Automatically when you click "Update now in BG" in dialog
**Mode**: Headless with edit permissions

**What it does:**

- Resumes the analysis session from post-commit hook
- Runs with Edit/Write permissions enabled
- Updates CLAUDE.md files automatically in background
- Shows notification when complete
- Logs output to `/tmp/claude_update_[SESSION_ID].json`

**Manual usage:**

```bash
# If you skip the dialog but want to update later
.husky/scripts/claude-update-docs.sh <SESSION_ID>

# Find session ID in terminal output after commit
```

**How it works:**

1. Uses session ID from analysis phase
2. Resumes Claude CLI with: `--resume SESSION_ID --tools "Edit,Write,Read" --permission-mode bypassPermissions`
3. Claude has full context from analysis
4. Makes edits directly to CLAUDE.md files
5. Returns success/failure notification

**Monitor progress:**

```bash
# Watch the update in real-time
tail -f /tmp/claude_update_*.json

# Check all recent updates
ls -lt /tmp/claude_update_*.json | head
```

---

### 3. `check-docs-interactive.sh` (Manual)

**Location**: `.husky/scripts/check-docs-interactive.sh`
**Runs**: Manually when you want to chat with Claude
**Mode**: Interactive (full Claude Code session)

**What it does:**

- Opens Claude Code with commit context pre-loaded
- Allows you to chat and ask questions
- Claude can read files, make changes, run tests
- Full agentic capabilities

**Usage:**

```bash
# After making a commit
.husky/scripts/check-docs-interactive.sh

# Or for a specific commit
git checkout <commit-hash>
.husky/scripts/check-docs-interactive.sh
```

---

## Configuration

### Automated Updates

**NEW:** The post-commit hook now supports automatic updates via macOS dialog!

**Behavior:**

- After analysis, if updates are needed, a dialog appears
- Click "Update now in BG" → Claude updates files automatically
- Click "Skip this time" → You handle updates manually (or later)
- Session ID preserved for 24 hours (can update later)

### Disable Auto-Check Globally

Edit `.husky/post-commit` and add at the top:

```bash
exit 0  # Disable documentation checks
```

### Disable for Specific Commits

Use commit message flags:

```bash
git commit -m "update readme [skip-docs]"
```

### Disable Dialog (Terminal Only)

If you want analysis without the popup dialog:

```bash
# Edit .husky/post-commit, comment out the osascript section (lines ~135-141)
# The analysis will still run and show terminal output
```

### Change Claude Model

Edit `.husky/post-commit` line with `--model`:

```bash
# Current:
--model sonnet

# Faster (less thorough):
--model haiku
```

### Adjust Max Turns

Edit `.husky/post-commit` line with `--max-turns`:

```bash
# Current:
--max-turns 5

# More analysis:
--max-turns 10
```

---

## How It Works

### Post-Commit Flow

```
1. Code committed
   ↓
2. post-commit hook triggered
   ↓
3. Extract commit info:
   - Changed files
   - Commit message
   - Git diff
   ↓
4. Build comprehensive prompt with:
   - List of all CLAUDE.md files
   - Update criteria
   - Diff context
   ↓
5. Run: echo "$PROMPT" | claude -p --model haiku
   ↓
6. Claude analyzes in headless mode
   ↓
7. Output recommendations
   ↓
8. Developer reviews and updates docs if needed
```

### Why Headless Mode?

- **Fast**: No UI overhead, instant analysis
- **Non-blocking**: Doesn't interrupt your workflow
- **Scriptable**: Can be extended, logged, or integrated with CI
- **Cost-effective**: Uses haiku model for quick analysis

### Why Post-Commit (not Pre-Commit)?

- **Non-blocking**: Commits complete immediately
- **Better analysis**: Can analyze the actual commit diff
- **Flexible**: Can batch multiple commits before updating docs
- **Optional**: Easy to skip when needed

---

## Troubleshooting

### "claude: command not found"

Install Claude Code CLI:

```bash
npm install -g claude-code
# or
brew install claude-code
```

### Hook not running

Make sure it's executable:

```bash
chmod +x .husky/post-commit
```

### Too much output

Reduce verbosity by limiting diff size in post-commit:

```bash
# Change this line:
DIFF=$(git show HEAD ... | head -1000)
# To:
DIFF=$(git show HEAD ... | head -500)
```

### Want more control

Use the interactive version instead:

```bash
.husky/scripts/check-docs-interactive.sh
```

---

## Advanced Usage

### Check Multiple Commits

```bash
# Check last 3 commits
for commit in $(git log -3 --format=%H); do
  git checkout $commit
  .husky/scripts/check-docs-interactive.sh
done
```

### Integrate with CI

Add to `.github/workflows/docs-check.yml`:

```yaml
- name: Check documentation
  run: |
    git diff HEAD^ HEAD | claude -p \
      --model haiku \
      --max-turns 5 \
      "Analyze this diff and check if CLAUDE.md files need updating"
```

### Custom Analysis

Create your own prompt:

```bash
git show HEAD | claude -p "Your custom analysis prompt here"
```

---

## Best Practices

### When to Update CLAUDE.md

**✅ Always Update:**

- New files added to module (components, hooks, services)
- Public API signatures changed
- Architecture patterns changed
- New dependencies with different patterns
- Performance characteristics changed

**❌ Don't Update:**

- Internal implementation (if API unchanged)
- Bug fixes (unless revealing new patterns)
- Formatting/linting changes
- Version bumps (unless new features)

### Commit Message Conventions

**For docs-only commits:**

```bash
git commit -m "docs: update hooks/CLAUDE.md with useDebounce"
```

**For code changes that don't need doc updates:**

```bash
git commit -m "fix: handle edge case in validation [skip-docs]"
```

**For code + docs together:**

```bash
# Make code changes
git add src/

# Commit code
git commit -m "feat: add useDebounce hook"

# Hook analyzes and recommends updates

# Update docs
git add src/app/hooks/CLAUDE.md
git commit --amend --no-edit

# Now both code and docs in one commit
```

---

## Maintenance

### Update the Analysis Prompt

Edit `.husky/post-commit` and modify the `PROMPT` variable.

### Add New CLAUDE.md Files

When adding new modules:

1. Create the CLAUDE.md file
2. Update the list in `.husky/post-commit`
3. Update the list in `.husky/scripts/check-docs-interactive.sh`

### Monitor Performance

Log execution time:

```bash
# Add to .husky/post-commit
START_TIME=$(date +%s)
# ... hook logic ...
END_TIME=$(date +%s)
echo "Analysis took $((END_TIME - START_TIME)) seconds"
```

---

## Examples

### Example 1: New Hook Added

```bash
$ git commit -m "feat: add useDebounce hook"
📚 Analyzing commit for documentation impact...
⚠️  Documentation update recommended!

File: /src/app/hooks/CLAUDE.md
Reason: New hook useDebounce added to hooks directory
Changes:
  - Add to "File Organization" section
  - Add to hook categories (likely "Utilities")
  - Document usage pattern
  - Add to common tasks

💡 Review suggestions above.
```

### Example 2: Internal Refactor

```bash
$ git commit -m "refactor: extract helper function"
📚 Analyzing commit for documentation impact...
✅ No documentation updates needed.
(Internal refactor, public API unchanged)
```

### Example 3: Skip Check

```bash
$ git commit -m "fix typo [skip-docs]"
📝 Skipping documentation check (commit message flag)
```

---

## Contributing

To improve the documentation check:

1. Test changes on small commits first
2. Monitor false positives/negatives
3. Adjust criteria in the prompt
4. Share improvements with the team
