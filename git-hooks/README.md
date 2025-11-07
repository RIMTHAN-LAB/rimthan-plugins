# Rimthan Universal Git Hooks

> **Multi-language Git hooks that work across JavaScript/TypeScript, Go, Dart/Flutter, and Python projects**

---

## 📁 Folder Structure

```
.husky/
├── 📄 README.md              # This file - Quick start guide
├── 🔧 install.sh             # Installation script for new repos
│
├── 🎣 Git Hooks (Husky requires these at root level)
│   ├── pre-commit            # Linting & type checking
│   ├── pre-push              # Tests & builds
│   └── post-commit           # CLAUDE.md documentation sync
│
├── 📚 lib/                   # Shared utility libraries
│   ├── detect-env.sh         # Tech stack auto-detection
│   ├── platform.sh           # Cross-platform helpers (UUID, notifications)
│   ├── config.sh             # Configuration file parser
│   ├── notify.py             # Desktop notifications (macOS/Linux/Windows)
│   └── uuid.py               # UUID generation (cross-platform)
│
├── 🛠️  scripts/              # Standalone executable scripts
│   ├── claude-update-docs.sh      # Background documentation updater
│   └── check-docs-interactive.sh  # Manual documentation checker
│
├── ⚙️  config/               # Configuration files
│   ├── config.json           # Active configuration (git-ignored by default)
│   └── config.example.json   # Configuration template
│
└── 📖 docs/                  # Documentation
    ├── README.md                      # Complete user guide
    ├── IMPLEMENTATION_SUMMARY.md      # Implementation details
    ├── WORKFLOW_DIAGRAM_UNIVERSAL.md  # Visual workflow diagram
    └── SCRIPTS_README.md              # Scripts documentation
```

---

## 🚀 Quick Start

### For This Repository (VoiceAgent)

Already installed and configured! The hooks are active.

**Test them:**
```bash
# Test pre-commit hook
git add .
git commit -m "test commit"

# Test pre-push hook
git push
```

### For New Repositories

1. **Copy the hooks:**
   ```bash
   cp -r /path/to/VoiceAgent/.husky /path/to/new-repo/.husky
   cd /path/to/new-repo
   ```

2. **Run installation:**
   ```bash
   .husky/install.sh
   ```

3. **Customize configuration (optional):**
   ```bash
   nano .husky/config/config.json
   ```

---

## ⚙️  Configuration

**Location:** `.husky/config/config.json`

**Default configuration:**
```json
{
  "enabled": {
    "preCommit": true,    // Enable pre-commit hook
    "postCommit": true,   // Enable post-commit (CLAUDE.md) hook
    "prePush": true       // Enable pre-push hook
  },
  "detection": {
    "auto": true,         // Auto-detect tech stacks
    "stacks": []          // Manual override (leave empty for auto)
  },
  "logs": {
    "directory": ".rimthan_cli"  // Where Claude logs are stored
  },
  "claude": {
    "model": "sonnet",           // Claude model (sonnet/opus/haiku)
    "maxTurns": 15,              // Max turns for analysis
    "enableAutoUpdate": true     // Allow background doc updates
  }
}
```

**To customize:**
- Copy `config.example.json` to `config.json`
- Edit values as needed
- Changes take effect immediately

---

## 🎯 What Each Hook Does

### pre-commit
**Runs:** Linting and type checking for changed files

**Supports:**
- ✅ **JavaScript/TypeScript:** lint-staged (ESLint, Prettier, TypeScript)
- 🔄 **Go:** golangci-lint, gofmt (coming soon)
- 🔄 **Dart/Flutter:** dart analyze, dart format (coming soon)
- 🔄 **Python:** ruff check, mypy (coming soon)

**Current behavior:** JavaScript/TypeScript only (others planned)

### pre-push
**Runs:** Tests and builds before pushing

**Supports:**
- ✅ **JavaScript/TypeScript:** npm/yarn/pnpm/bun test + build
- ✅ **Go:** go test ./... + go build ./...
- ✅ **Dart/Flutter:** flutter test / dart test
- ✅ **Python:** pytest / unittest discover

**Behavior:** Fully implemented for all languages!

### post-commit
**Runs:** CLAUDE.md documentation synchronization check

**What it does:**
1. Analyzes committed changes
2. Detects which CLAUDE.md files might need updates
3. Runs Claude CLI analysis in headless mode
4. Prompts to auto-update if changes needed
5. Updates documentation in background if approved

**Supports:** All languages (uses auto-detected file patterns)

---

## 🔧 Utilities Library

### lib/detect-env.sh
**Auto-detects tech stacks and provides stack-specific patterns**

Key functions:
- `detect_stacks()` - Find all tech stacks in repo
- `detect_changed_stacks()` - Find stacks with changes in commit
- `get_extensions(stack)` - Get file extensions for a stack
- `get_exclude_paths(stack)` - Get build/cache directories to exclude
- `get_lock_files(stack)` - Get lock files to skip
- `detect_package_manager()` - Find JS package manager (npm/yarn/pnpm/bun)

### lib/platform.sh
**Cross-platform helpers for macOS/Linux/Windows**

Key functions:
- `generate_uuid()` - UUID v4 generation (works everywhere)
- `send_notification(title, message)` - Desktop notifications
- `detect_os()` - Get OS type (macos/linux/windows)
- `is_ci()` - Check if running in CI

### lib/config.sh
**Reads configuration from config/config.json**

Key functions:
- `get_config(key, default)` - Get config value
- `is_enabled(feature)` - Check if feature enabled
- `get_logs_dir()` - Get logs directory path
- `get_claude_model()` - Get Claude model name

---

## 📊 Tech Stack Detection

**How it works:**

1. **Project Detection:**
   - JavaScript/TypeScript: `package.json`
   - Go: `go.mod`
   - Dart/Flutter: `pubspec.yaml`
   - Python: `pyproject.toml`, `requirements.txt`

2. **Change Detection:**
   - Analyzes git diff for file extensions
   - Only runs hooks for affected stacks
   - Builds dynamic patterns based on changes

3. **Benefits:**
   - Faster hook execution (only relevant checks)
   - Works in monorepos with multiple languages
   - Automatically adapts to new projects

---

## 🛠️  Troubleshooting

### Hooks Not Running
```bash
# Make hooks executable
chmod +x .husky/pre-commit .husky/pre-push .husky/post-commit
chmod +x .husky/lib/*.sh .husky/lib/*.py
chmod +x .husky/scripts/*.sh
```

### Configuration Not Working
```bash
# Check if config file exists
ls -la .husky/config/config.json

# Test config reading
source .husky/lib/config.sh && get_logs_dir
```

### Detection Not Working
```bash
# Test stack detection
source .husky/lib/detect-env.sh && detect_stacks
```

### Cross-Platform Issues
- **UUID:** Requires Python 3 (fallback: uuidgen, /proc/sys/kernel/random/uuid)
- **Notifications:** Requires Python 3 (fallback: OS-specific commands)

---

## 📚 Full Documentation

**For detailed information, see:**

- **[docs/README.md](docs/README.md)** - Complete user guide
- **[docs/WORKFLOW_DIAGRAM_UNIVERSAL.md](docs/WORKFLOW_DIAGRAM_UNIVERSAL.md)** - Visual workflow
- **[docs/IMPLEMENTATION_SUMMARY.md](docs/IMPLEMENTATION_SUMMARY.md)** - Technical details

**For quick reference:**
- Want to disable a hook? Edit `config/config.json`
- Want to skip doc check? Add `[skip-docs]` to commit message
- Want to bypass all hooks? Use `git commit --no-verify`

---

## 💡 Common Tasks

### Disable CLAUDE.md Automation
```json
// In config/config.json
{
  "enabled": {
    "postCommit": false  // Disable post-commit hook
  }
}
```

### Change Claude Model
```json
// In config/config.json
{
  "claude": {
    "model": "opus"  // Use opus instead of sonnet
  }
}
```

### Skip Documentation Check (One-Time)
```bash
git commit -m "fix typo [skip-docs]"
```

### View Claude Logs
```bash
# List all logs
ls -lh .rimthan_cli/

# View specific log
cat .rimthan_cli/claude_update_<session-id>.json

# Monitor active update
tail -f .rimthan_cli/claude_update_<session-id>.json
```

---

## 🤝 Support

**Questions or issues?**
- Read the full docs: `docs/README.md`
- Check troubleshooting: Above section
- Ask in #engineering-tools Slack channel
- Create issue in VoiceAgent repo

---

**Version:** 1.0
**Last Updated:** 2025-11-04
**Status:** ✅ Production Ready
