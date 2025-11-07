# Universal Git Hooks Workflow Diagram

```ascii
┌─────────────────────────────────────────────────────────────────────────────┐
│                    RIMTHAN UNIVERSAL GIT HOOKS SYSTEM                       │
│              Supports: JS/TS • Go • Dart/Flutter • Python                   │
└─────────────────────────────────────────────────────────────────────────────┘

                              ╔═══════════════╗
                              ║  git commit   ║
                              ╚═══════╤═══════╝
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ PRE-COMMIT HOOK (Universal Auto-Detection)                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│  1. Source utilities:                                                        │
│     • lib/detect-env.sh    (tech stack detection)                           │
│     • lib/config.sh        (configuration reader)                           │
│                                                                              │
│  2. Check if enabled in config.json                                         │
│     config.enabled.preCommit == true → Continue                             │
│                                        false → Skip                          │
│                                                                              │
│  3. Auto-detect changed tech stacks:                                        │
│     ┌────────────────────────────────────────────────────────┐             │
│     │ detect_changed_stacks() analyzes git diff:             │             │
│     │                                                         │             │
│     │ • JavaScript/TypeScript                                │             │
│     │   Files: *.js, *.jsx, *.ts, *.tsx, *.mjs, *.cjs       │             │
│     │   Marker: package.json changed                         │             │
│     │                                                         │             │
│     │ • Go                                                    │             │
│     │   Files: *.go                                          │             │
│     │   Marker: go.mod or go.sum changed                     │             │
│     │                                                         │             │
│     │ • Dart/Flutter                                         │             │
│     │   Files: *.dart                                        │             │
│     │   Marker: pubspec.yaml changed                         │             │
│     │                                                         │             │
│     │ • Python                                               │             │
│     │   Files: *.py, *.pyx, *.pyi                           │             │
│     │   Marker: pyproject.toml, requirements.txt changed     │             │
│     └────────────────────────────────────────────────────────┘             │
│                                                                              │
│  4. Run stack-specific linting:                                             │
│                                                                              │
│     JavaScript/TypeScript:                                                  │
│     ┌──────────────────────────────────────────────────────────┐           │
│     │ if "lint-staged" in package.json:                        │           │
│     │   npx lint-staged                                        │           │
│     │   ├─ ESLint/Biome (linting)                             │           │
│     │   ├─ Prettier/Biome (formatting)                        │           │
│     │   └─ tsc --noEmit (type checking)                       │           │
│     └──────────────────────────────────────────────────────────┘           │
│                                                                              │
│     Go: (TODO - not yet implemented)                                        │
│     ┌──────────────────────────────────────────────────────────┐           │
│     │ golangci-lint run                                        │           │
│     │ gofmt -w .                                               │           │
│     └──────────────────────────────────────────────────────────┘           │
│                                                                              │
│     Dart/Flutter: (TODO)                                                    │
│     ┌──────────────────────────────────────────────────────────┐           │
│     │ dart analyze                                             │           │
│     │ dart format .                                            │           │
│     └──────────────────────────────────────────────────────────┘           │
│                                                                              │
│     Python: (TODO)                                                          │
│     ┌──────────────────────────────────────────────────────────┐           │
│     │ ruff check --fix                                         │           │
│     │ ruff format                                              │           │
│     │ mypy .                                                   │           │
│     └──────────────────────────────────────────────────────────┘           │
│                                                                              │
│  Result: ✅ All pass → commit proceeds                                      │
│          ❌ Any fail → commit BLOCKED                                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
                              ╔═══════════════╗
                              ║ Commit Saved  ║
                              ╚═══════╤═══════╝
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ POST-COMMIT HOOK - CLAUDE.md Documentation Checker (Universal)              │
├─────────────────────────────────────────────────────────────────────────────┤
│  1. Source utilities:                                                        │
│     • lib/detect-env.sh    (tech stack detection)                           │
│     • lib/platform.sh      (cross-platform helpers)                         │
│     • lib/config.sh        (configuration reader)                           │
│                                                                              │
│  2. Check if enabled: config.enabled.postCommit                             │
│                                                                              │
│  3. Get commit info and detect changed stacks                               │
│                                                                              │
│  4. Build file patterns dynamically:                                        │
│     ┌────────────────────────────────────────────────────────┐             │
│     │ For each detected stack:                               │             │
│     │   get_extensions(stack) → extensions list              │             │
│     │   get_lock_files(stack) → lock files to exclude        │             │
│     │                                                         │             │
│     │ Example output for javascript + python:                │             │
│     │   Extensions: js,jsx,ts,tsx,mjs,cjs,mts,cts,py,pyi    │             │
│     │   Lock files: package-lock.json, poetry.lock           │             │
│     └────────────────────────────────────────────────────────┘             │
│                                                                              │
│  5. Filter changed files (exclude CLAUDE.md and lock files)                 │
│     Skip if no relevant code files changed                                  │
│                                                                              │
│  6. Check skip flags:                                                       │
│     • [skip-docs] in commit message → SKIP                                  │
│     • [docs-skip] in commit message → SKIP                                  │
│                                                                              │
│  7. Generate session ID:                                                    │
│     ┌────────────────────────────────────────────────────────┐             │
│     │ SESSION_ID = generate_uuid()  (cross-platform)         │             │
│     │                                                         │             │
│     │ Fallback order:                                        │             │
│     │ 1. uuidgen (macOS/Linux)                               │             │
│     │ 2. /proc/sys/kernel/random/uuid (Linux)                │             │
│     │ 3. python3 lib/uuid.py (universal)                     │             │
│     │ 4. powershell [guid] (Windows)                         │             │
│     └────────────────────────────────────────────────────────┘             │
│                                                                              │
│  8. Build git diff with detected patterns:                                  │
│     git show HEAD -- *.{ext1,ext2,...} :!*CLAUDE.md :!*lock                │
│                                                                              │
│  9. Discover CLAUDE.md files with dynamic excludes:                         │
│     ┌────────────────────────────────────────────────────────┐             │
│     │ exclude_paths = get_all_exclude_paths()                │             │
│     │                                                         │             │
│     │ JavaScript: node_modules, .next, .nuxt, dist, build    │             │
│     │ Go: vendor, bin, pkg, _obj                             │             │
│     │ Dart/Flutter: .dart_tool, build, .pub                  │             │
│     │ Python: __pycache__, .venv, dist, build                │             │
│     │                                                         │             │
│     │ find . -name "CLAUDE.md" -not -path "*/{excludes}/*"   │             │
│     └────────────────────────────────────────────────────────┘             │
│                                                                              │
│ 10. Launch Claude CLI analysis:                                             │
│     ┌──────────────────────────────────────────────────────────┐           │
│     │ claude -p                                                │           │
│     │   --model $(get_claude_model)        # from config      │           │
│     │   --max-turns $(get_claude_max_turns) # from config      │           │
│     │   --tools "Read,Grep,Glob"           # read-only        │           │
│     │   --session-id $SESSION_ID                               │           │
│     │   --output-format json                                   │           │
│     │                                                          │           │
│     │ Provides: commit hash, message, diff, CLAUDE.md list    │           │
│     └──────────────────────────────────────────────────────────┘           │
│                                                                              │
│ 11. Parse result:                                                           │
│                                                                              │
│     ┌───────────────────────────────────────────────────────────┐          │
│     │ "NO_UPDATE_NEEDED"                                        │          │
│     │   → ✅ Print success                                      │          │
│     │   → Exit                                                  │          │
│     └───────────────────────────────────────────────────────────┘          │
│                          │                                                  │
│     ┌───────────────────────────────────────────────────────────┐          │
│     │ "UPDATE_RECOMMENDED"                                      │          │
│     │   → ⚠️  Show dialog with affected files                   │          │
│     │   → User choice:                                          │          │
│     │                                                            │          │
│     │   ┌─────────────────────┐    ┌──────────────────────┐    │          │
│     │   │ "Skip this time"    │    │ "Update now in BG"   │    │          │
│     │   └──────────┬──────────┘    └──────────┬───────────┘    │          │
│     │              │                           │                │          │
│     │              ▼                           ▼                │          │
│     │     Print manual command      Launch background script    │          │
│     │     for later re-run          (scripts/                   │          │
│     │                                claude-update-docs.sh)      │          │
│     │                                                            │          │
│     │     Send notification:                                    │          │
│     │     send_notification() (cross-platform)                  │          │
│     │     ├─ macOS: osascript                                   │          │
│     │     ├─ Linux: notify-send                                 │          │
│     │     └─ Windows: powershell toast                          │          │
│     └───────────────────────────────────────────────────────────┘          │
│                                                                              │
│ Background Update Process (if approved):                                    │
│  ┌────────────────────────────────────────────────────────────────┐        │
│  │ 1. Sources lib/platform.sh and lib/config.sh                   │        │
│  │ 2. LOGS_DIR = get_logs_dir()  # from config                    │        │
│  │ 3. Resume session: claude --resume $SESSION_ID                 │        │
│  │ 4. Enable edit tools: --tools "Edit,Write,Read"                │        │
│  │ 5. Bypass permissions: --permission-mode bypassPermissions      │        │
│  │ 6. Max 20 turns to complete updates                             │        │
│  │ 7. Log to: $(get_logs_dir)/claude_update_${SESSION_ID}.json    │        │
│  │ 8. Cross-platform notification on completion                    │        │
│  │    send_notification "Claude Code Update" "Success/Failure"     │        │
│  └────────────────────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
                          ╔═══════════════════════╗
                          ║  Local commit done    ║
                          ╚═══════════╤═══════════╝
                                      │
                                      ▼
                              ╔═══════════════╗
                              ║   git push    ║
                              ╚═══════╤═══════╝
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ PRE-PUSH HOOK (Universal Multi-Language)                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  1. Source utilities and check if enabled                                   │
│                                                                              │
│  2. Detect all tech stacks in repository:                                   │
│     stacks = detect_stacks()                                                │
│                                                                              │
│  3. Run tests and builds per detected stack:                                │
│                                                                              │
│     ┌─────────────────────────────────────────────────────────┐            │
│     │ JavaScript/TypeScript:                                  │            │
│     │                                                          │            │
│     │ 1. Detect package manager:                              │            │
│     │    detect_package_manager() checks:                     │            │
│     │    • bun.lockb       → bun                              │            │
│     │    • pnpm-lock.yaml  → pnpm                             │            │
│     │    • yarn.lock       → yarn                             │            │
│     │    • package-lock.json → npm                            │            │
│     │                                                          │            │
│     │ 2. Run tests (if "test" script exists):                │            │
│     │    npm test  / yarn test / pnpm test / bun test        │            │
│     │                                                          │            │
│     │ 3. Run build (if "build" script exists):               │            │
│     │    npm run build / yarn build / pnpm build / bun build │            │
│     └─────────────────────────────────────────────────────────┘            │
│                                                                              │
│     ┌─────────────────────────────────────────────────────────┐            │
│     │ Go:                                                      │            │
│     │                                                          │            │
│     │ 1. go test ./...       # Run all tests                  │            │
│     │ 2. go build ./...      # Build all packages             │            │
│     └─────────────────────────────────────────────────────────┘            │
│                                                                              │
│     ┌─────────────────────────────────────────────────────────┐            │
│     │ Dart/Flutter:                                            │            │
│     │                                                          │            │
│     │ if grep -q "flutter:" pubspec.yaml:                     │            │
│     │   flutter test        # Flutter project                 │            │
│     │ else:                                                    │            │
│     │   dart test          # Pure Dart project                │            │
│     └─────────────────────────────────────────────────────────┘            │
│                                                                              │
│     ┌─────────────────────────────────────────────────────────┐            │
│     │ Python:                                                  │            │
│     │                                                          │            │
│     │ if command -v pytest:                                   │            │
│     │   pytest                                                │            │
│     │ else:                                                    │            │
│     │   python3 -m unittest discover                          │            │
│     └─────────────────────────────────────────────────────────┘            │
│                                                                              │
│  Result: ✅ All pass → push proceeds                                        │
│          ❌ Any fail → push BLOCKED                                         │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
                              ╔═══════════════╗
                              ║ Push Complete ║
                              ╚═══════════════╝


┌─────────────────────────────────────────────────────────────────────────────┐
│ CROSS-PLATFORM COMPATIBILITY                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  UUID Generation (lib/platform.sh: generate_uuid)                           │
│  ┌────────────────────────────────────────────────────────┐                │
│  │ 1. Try: uuidgen               (macOS, Linux)           │                │
│  │ 2. Try: /proc/.../uuid        (Linux kernel)           │                │
│  │ 3. Try: python3 lib/uuid.py   (Universal)             │                │
│  │ 4. Try: powershell [guid]     (Windows)                │                │
│  │ 5. Fallback: /dev/urandom     (Pseudo-UUID)            │                │
│  └────────────────────────────────────────────────────────┘                │
│                                                                              │
│  Desktop Notifications (lib/platform.sh: send_notification)                 │
│  ┌────────────────────────────────────────────────────────┐                │
│  │ 1. Try: python3 lib/notify.py  (Universal)            │                │
│  │ 2. Fallback by OS:                                     │                │
│  │    • macOS: osascript                                  │                │
│  │    • Linux: notify-send                                │                │
│  │    • Windows: powershell toast                         │                │
│  └────────────────────────────────────────────────────────┘                │
│                                                                              │
│  Configuration (lib/config.sh: get_config)                                  │
│  ┌────────────────────────────────────────────────────────┐                │
│  │ 1. Try: python3 JSON parser    (Reliable)             │                │
│  │ 2. Fallback: grep + sed        (Basic parsing)         │                │
│  │ 3. Default: return fallback value                      │                │
│  └────────────────────────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────┐
│ KEY FEATURES & IMPROVEMENTS                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ✅ Universal Tech Stack Support:                                           │
│     • JavaScript/TypeScript (npm, yarn, pnpm, bun)                          │
│     • Go (go modules)                                                       │
│     • Dart/Flutter (pub)                                                    │
│     • Python (pip, poetry, pipenv)                                          │
│                                                                              │
│  ✅ Smart Auto-Detection:                                                   │
│     • Detects stacks from project files (package.json, go.mod, etc.)       │
│     • Detects changed stacks from git diff                                  │
│     • Only runs hooks for relevant tech stacks                              │
│     • Dynamic file extension patterns per stack                             │
│                                                                              │
│  ✅ Cross-Platform Compatibility:                                           │
│     • Works on macOS, Linux, Windows                                        │
│     • Python fallbacks for maximum portability                              │
│     • No OS-specific dependencies required                                  │
│                                                                              │
│  ✅ Configurable & Flexible:                                                │
│     • Optional config.json with sensible defaults                           │
│     • Enable/disable hooks individually                                     │
│     • Customize Claude model and behavior                                   │
│     • Custom logs directory                                                 │
│                                                                              │
│  ✅ Developer Friendly:                                                     │
│     • Zero configuration required (works out of box)                        │
│     • Clear error messages and status output                                │
│     • Skip flags: [skip-docs], [docs-skip], --no-verify                    │
│     • Persistent logs in .rimthan_cli/                                      │
│                                                                              │
│  ✅ CLAUDE.md Automation Enhanced:                                          │
│     • Dynamic file pattern detection                                        │
│     • Dynamic exclude path detection                                        │
│     • Cross-platform notifications                                          │
│     • Configurable from config.json                                         │
└─────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────┐
│ DEPLOYMENT TO OTHER REPOS                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Method 1: Direct Copy                                                      │
│  ┌────────────────────────────────────────────────────────┐                │
│  │ 1. cp -r .husky /path/to/other-repo/.husky            │                │
│  │ 2. cd /path/to/other-repo                             │                │
│  │ 3. .husky/install.sh                                  │                │
│  │ 4. Customize .husky/config.json if needed             │                │
│  └────────────────────────────────────────────────────────┘                │
│                                                                              │
│  Method 2: Git Subtree (Advanced)                                           │
│  ┌────────────────────────────────────────────────────────┐                │
│  │ git subtree add --prefix .husky \                      │                │
│  │   https://github.com/org/VoiceAgent.git \             │                │
│  │   master:.husky --squash                               │                │
│  └────────────────────────────────────────────────────────┘                │
│                                                                              │
│  Method 3: Company Template Repo                                            │
│  ┌────────────────────────────────────────────────────────┐                │
│  │ 1. Create rimthan-git-hooks repo                       │                │
│  │ 2. Copy .husky/ contents there                         │                │
│  │ 3. In any repo:                                        │                │
│  │    git clone <hooks-repo-url> .husky                   │                │
│  │    .husky/install.sh                                   │                │
│  └────────────────────────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────┘
```
