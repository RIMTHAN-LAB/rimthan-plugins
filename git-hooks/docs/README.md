# Rimthan Universal Git Hooks

Universal Git hooks that work across JavaScript/TypeScript, Go, Dart/Flutter, and Python projects.

## Features

✅ **Multi-Language Support**
- JavaScript/TypeScript (npm, yarn, pnpm, bun)
- Go (go modules)
- Dart/Flutter (pub)
- Python (pip, poetry, pipenv)

✅ **Smart Detection**
- Auto-detects tech stacks from project files
- Only runs hooks for changed code
- Dynamic file extension patterns
- Intelligent build/cache directory exclusion

✅ **Cross-Platform**
- Works on macOS, Linux, and Windows
- Platform-agnostic UUID generation
- Cross-platform desktop notifications
- No OS-specific dependencies

✅ **CLAUDE.md Automation**
- Automated documentation sync checking
- Background updates with user approval
- Persistent logs in `.rimthan_cli/`
- Configurable Claude model and behavior

---

## Installation

### For New Repositories

1. Copy the entire `.husky/` directory to your repo
2. Run the installation script:
   ```bash
   .husky/install.sh
   ```
3. Customize `.husky/config.json` if needed
4. Make a test commit to verify hooks work

### For Existing VoiceAgent Repo

Already installed! Hooks are active and configured.

---

## Hook Behavior

### pre-commit
Runs linting and type checking for changed files:

**JavaScript/TypeScript:**
- Runs `lint-staged` if configured in `package.json`
- Executes ESLint, Prettier, TypeScript compiler

**Other Languages:** (Planned)
- Go: `golangci-lint`, `gofmt`
- Dart/Flutter: `dart analyze`, `dart format`
- Python: `ruff check`, `mypy`

### pre-push
Runs tests and builds before pushing:

**JavaScript/TypeScript:**
- Detects package manager (npm/yarn/pnpm/bun)
- Runs `test` script if exists
- Runs `build` script if exists

**Go:**
- `go test ./...`
- `go build ./...`

**Dart/Flutter:**
- `flutter test` or `dart test`

**Python:**
- `pytest` or `unittest discover`

### post-commit
Checks if CLAUDE.md files need updating:

1. Analyzes committed changes
2. Detects affected tech stacks
3. Scans for CLAUDE.md files (excluding build dirs)
4. Runs Claude CLI analysis
5. Prompts user to auto-update if changes needed
6. Updates documentation in background if approved

---

## Configuration

### config.json

Optional configuration file with sensible defaults:

```json
{
  "enabled": {
    "preCommit": true,
    "postCommit": true,
    "prePush": true
  },
  "detection": {
    "auto": true,
    "stacks": []
  },
  "logs": {
    "directory": ".rimthan_cli"
  },
  "claude": {
    "model": "sonnet",
    "maxTurns": 15,
    "enableAutoUpdate": true
  },
  "notifications": {
    "enabled": true
  }
}
```

### Disabling Hooks

**Temporarily (single commit):**
```bash
git commit --no-verify -m "message"
```

**Permanently for this repo:**
Edit `.husky/config.json`:
```json
{
  "enabled": {
    "preCommit": false,
    "postCommit": false,
    "prePush": false
  }
}
```

**Skip documentation check only:**
Add `[skip-docs]` or `[docs-skip]` to commit message:
```bash
git commit -m "fix typo [skip-docs]"
```

---

## Tech Stack Detection

### How It Works

1. **Project Files:** Checks for marker files
   - JS/TS: `package.json`
   - Go: `go.mod`
   - Dart/Flutter: `pubspec.yaml`
   - Python: `pyproject.toml`, `requirements.txt`

2. **Changed Files:** Analyzes file extensions in commit
   - JS/TS: `.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs`
   - Go: `.go`
   - Dart: `.dart`
   - Python: `.py`, `.pyx`, `.pyi`

3. **Dynamic Patterns:** Builds patterns based on detected stacks
   - File extensions for diffs
   - Exclude paths for CLAUDE.md search
   - Lock files to skip in analysis

---

## File Structure

```
.husky/
├── config.json                # Optional configuration
├── install.sh                 # Setup script for new repos
├── pre-commit                 # Linting hook
├── pre-push                   # Testing/build hook
├── post-commit                # CLAUDE.md automation
├── lib/                       # Shared utilities
│   ├── detect-env.sh         # Tech stack detection
│   ├── platform.sh           # Cross-platform helpers
│   ├── config.sh             # Config file parser
│   ├── notify.py             # Desktop notifications
│   └── uuid.py               # UUID generation
└── scripts/
    ├── claude-update-docs.sh       # Background updater
    └── check-docs-interactive.sh   # Manual doc check
```

---

## Utilities Library

### detect-env.sh

**Functions:**
- `detect_stacks` - Find all tech stacks in repo
- `detect_changed_stacks` - Find stacks with changes
- `get_extensions` - Get file extensions for a stack
- `get_exclude_paths` - Get build/cache directories
- `get_lock_files` - Get lock files to exclude
- `detect_package_manager` - Find JS package manager
- `detect_python_package_manager` - Find Python package manager

**Example:**
```bash
source .husky/lib/detect-env.sh
stacks=$(detect_stacks)
echo "Found: $stacks"  # Output: javascript go python
```

### platform.sh

**Functions:**
- `generate_uuid` - Cross-platform UUID generation
- `send_notification` - Cross-platform desktop notifications
- `detect_os` - Get OS type (macos/linux/windows)
- `is_ci` - Check if running in CI environment

**Example:**
```bash
source .husky/lib/platform.sh
uuid=$(generate_uuid)
send_notification "Title" "Message"
```

### config.sh

**Functions:**
- `get_config` - Get config value with fallback
- `is_enabled` - Check if feature is enabled
- `get_logs_dir` - Get logs directory path
- `get_claude_model` - Get Claude model name
- `is_auto_update_enabled` - Check auto-update setting

**Example:**
```bash
source .husky/lib/config.sh
if is_enabled "preCommit"; then
    echo "Pre-commit hook is enabled"
fi
```

---

## Logs

All Claude CLI operations log to `.rimthan_cli/`:

```bash
# Monitor active update
tail -f .rimthan_cli/claude_update_<session-id>.json

# List all logs
ls -lh .rimthan_cli/

# View specific log
cat .rimthan_cli/claude_update_<session-id>.json
```

---

## Troubleshooting

### Hooks Not Running

1. Check if hooks are executable:
   ```bash
   chmod +x .husky/pre-commit .husky/pre-push .husky/post-commit
   ```

2. Verify Husky is initialized:
   ```bash
   npx husky init
   ```

3. Check config.json:
   ```bash
   cat .husky/config.json
   ```

### Cross-Platform Issues

**UUID Generation:**
- Requires Python 3 or `uuidgen` command
- Fallback: reads from `/proc/sys/kernel/random/uuid` (Linux)

**Notifications:**
- macOS: Uses `osascript` (built-in)
- Linux: Requires `notify-send` (install: `apt install libnotify-bin`)
- Windows: Uses PowerShell (built-in)

### Detection Not Working

1. Verify marker files exist:
   ```bash
   ls package.json go.mod pubspec.yaml pyproject.toml
   ```

2. Test detection manually:
   ```bash
   source .husky/lib/detect-env.sh
   detect_stacks
   ```

3. Check file extensions in commit:
   ```bash
   git diff --cached --name-only
   ```

---

## Deployment to Other Repos

### Method 1: Copy Entire Directory

```bash
# From VoiceAgent repo
cp -r .husky /path/to/other-repo/.husky
cd /path/to/other-repo
.husky/install.sh
```

### Method 2: Git Subtree (Advanced)

```bash
# In target repo
git subtree add --prefix .husky \
  https://github.com/your-org/VoiceAgent.git \
  master:.husky --squash
```

### Method 3: Company Template Repo

1. Create `git-hooks-universal` repo
2. Copy `.husky/` contents there
3. Clone into any new repo:
   ```bash
   git clone https://github.com/your-org/git-hooks-universal .husky
   .husky/install.sh
   ```

---

## Contributing

When adding support for new languages:

1. Update `detect-env.sh`:
   - Add detection logic to `detect_stacks()`
   - Add file extensions to `get_extensions()`
   - Add exclude paths to `get_exclude_paths()`
   - Add lock files to `get_lock_files()`

2. Update hook files:
   - Add linting logic to `pre-commit`
   - Add test/build logic to `pre-push`

3. Test thoroughly across platforms

4. Update this documentation

---

## License

Proprietary - Rimthan Internal Use Only

---

## Support

Questions or issues? Contact:
- DevOps Team
- #engineering-tools Slack channel
- Create issue in VoiceAgent repo
