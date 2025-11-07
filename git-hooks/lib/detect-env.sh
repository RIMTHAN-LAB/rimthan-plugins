#!/bin/bash
# Universal Tech Stack Detection Library
# Detects JavaScript/TypeScript, Go, Dart/Flutter, and Python projects

# Detect all tech stacks in current directory
detect_stacks() {
    local dir="${1:-.}"
    local stacks=()

    # JavaScript/TypeScript - check for package.json
    [ -f "$dir/package.json" ] && stacks+=("javascript")

    # Go - check for go.mod
    [ -f "$dir/go.mod" ] && stacks+=("go")

    # Dart/Flutter - check for pubspec.yaml
    if [ -f "$dir/pubspec.yaml" ]; then
        # Check if it's Flutter (has flutter: section) or pure Dart
        if grep -q "flutter:" "$dir/pubspec.yaml" 2>/dev/null; then
            stacks+=("flutter")
        else
            stacks+=("dart")
        fi
    fi

    # Python - check for multiple indicators
    if [ -f "$dir/pyproject.toml" ] || [ -f "$dir/requirements.txt" ] || [ -f "$dir/setup.py" ]; then
        stacks+=("python")
    fi

    printf '%s\n' "${stacks[@]}"
}

# Detect tech stacks based on changed files (for git hooks)
detect_changed_stacks() {
    local changed=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null)
    [ -z "$changed" ] && changed=$(git diff --name-only --diff-filter=ACMR 2>/dev/null)

    local stacks=()

    # JavaScript/TypeScript files
    if echo "$changed" | grep -qE '\.(js|jsx|ts|tsx|mjs|cjs|mts|cts)$|package\.json'; then
        stacks+=("javascript")
    fi

    # Go files
    if echo "$changed" | grep -qE '\.go$|go\.(mod|sum)'; then
        stacks+=("go")
    fi

    # Dart/Flutter files
    if echo "$changed" | grep -qE '\.dart$|pubspec\.yaml'; then
        if [ -f "pubspec.yaml" ] && grep -q "flutter:" "pubspec.yaml" 2>/dev/null; then
            stacks+=("flutter")
        else
            stacks+=("dart")
        fi
    fi

    # Python files
    if echo "$changed" | grep -qE '\.py$|pyproject\.toml|requirements\.txt|setup\.py'; then
        stacks+=("python")
    fi

    printf '%s\n' "${stacks[@]}" | sort -u
}

# Get file extensions for a given stack
get_extensions() {
    local stack="$1"

    case "$stack" in
        javascript)
            echo "js,jsx,ts,tsx,mjs,cjs,mts,cts"
            ;;
        go)
            echo "go"
            ;;
        dart|flutter)
            echo "dart"
            ;;
        python)
            echo "py,pyw,pyx,pyi"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Get build/cache directories to exclude for a given stack
get_exclude_paths() {
    local stack="$1"

    case "$stack" in
        javascript)
            echo "node_modules .next .nuxt dist build out .turbo coverage .cache .parcel-cache .vite .webpack"
            ;;
        go)
            echo "vendor bin pkg _obj _test"
            ;;
        dart|flutter)
            echo ".dart_tool build .pub android/build ios/build"
            ;;
        python)
            echo "__pycache__ .pytest_cache .mypy_cache .ruff_cache dist build .eggs venv .venv env"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Get lock files to exclude from diffs for a given stack
get_lock_files() {
    local stack="$1"

    case "$stack" in
        javascript)
            echo "package-lock.json yarn.lock pnpm-lock.yaml bun.lockb"
            ;;
        go)
            echo "go.sum"
            ;;
        dart|flutter)
            echo "pubspec.lock"
            ;;
        python)
            echo "poetry.lock Pipfile.lock"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Get all exclude paths for all detected stacks (for CLAUDE.md search)
get_all_exclude_paths() {
    local stacks=$(detect_stacks)
    local all_paths=()

    for stack in $stacks; do
        local paths=$(get_exclude_paths "$stack")
        for path in $paths; do
            all_paths+=("$path")
        done
    done

    # Remove duplicates and output
    printf '%s\n' "${all_paths[@]}" | sort -u
}

# Get all lock files for all detected stacks
get_all_lock_files() {
    local stacks=$(detect_stacks)
    local all_locks=()

    for stack in $stacks; do
        local locks=$(get_lock_files "$stack")
        for lock in $locks; do
            all_locks+=("$lock")
        done
    done

    # Remove duplicates and output
    printf '%s\n' "${all_locks[@]}" | sort -u
}

# Get file extensions pattern for git diff (e.g., "*.ts *.tsx *.js")
get_git_diff_pattern() {
    local stacks=$(detect_changed_stacks)
    local patterns=()

    for stack in $stacks; do
        local exts=$(get_extensions "$stack")
        IFS=',' read -ra EXT_ARRAY <<< "$exts"
        for ext in "${EXT_ARRAY[@]}"; do
            patterns+=("*.$ext")
        done
    done

    printf '%s ' "${patterns[@]}"
}

# Detect package manager for JavaScript/TypeScript projects
detect_package_manager() {
    # Check for lock files (most reliable)
    if [ -f "bun.lockb" ]; then
        echo "bun"
    elif [ -f "pnpm-lock.yaml" ]; then
        echo "pnpm"
    elif [ -f "yarn.lock" ]; then
        echo "yarn"
    elif [ -f "package-lock.json" ]; then
        echo "npm"
    # Check package.json for packageManager field
    elif [ -f "package.json" ] && grep -q '"packageManager"' package.json; then
        local pm=$(grep '"packageManager"' package.json | sed -E 's/.*"packageManager".*"([^@"]+).*/\1/')
        echo "$pm"
    # Check if commands exist
    elif command -v bun &> /dev/null; then
        echo "bun"
    elif command -v pnpm &> /dev/null; then
        echo "pnpm"
    elif command -v yarn &> /dev/null; then
        echo "yarn"
    else
        echo "npm"
    fi
}

# Detect Python package manager
detect_python_package_manager() {
    if [ -f "pyproject.toml" ] && grep -q "\[tool.poetry\]" pyproject.toml 2>/dev/null; then
        echo "poetry"
    elif [ -f "Pipfile" ]; then
        echo "pipenv"
    elif [ -f "environment.yml" ]; then
        echo "conda"
    else
        echo "pip"
    fi
}
