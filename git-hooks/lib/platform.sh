#!/bin/bash
# Cross-Platform Utility Functions
# Provides platform-agnostic implementations for UUID generation and notifications

# Get the directory where this library is located
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Generate a UUID (cross-platform)
generate_uuid() {
    # Try uuidgen (macOS, Linux with uuid-runtime)
    if command -v uuidgen &> /dev/null; then
        uuidgen
        return 0
    fi

    # Try Linux kernel interface
    if [ -f /proc/sys/kernel/random/uuid ]; then
        cat /proc/sys/kernel/random/uuid
        return 0
    fi

    # Try Python script (most portable)
    if command -v python3 &> /dev/null && [ -f "$LIB_DIR/uuid.py" ]; then
        python3 "$LIB_DIR/uuid.py"
        return 0
    fi

    # Try PowerShell (Windows)
    if command -v powershell &> /dev/null; then
        powershell -Command "[guid]::NewGuid().ToString()"
        return 0
    fi

    # Fallback: generate pseudo-UUID from random data
    cat /dev/urandom | LC_ALL=C tr -dc 'a-f0-9' | fold -w 32 | head -n 1 | sed -e 's/\(.\{8\}\)\(.\{4\}\)\(.\{4\}\)\(.\{4\}\)/\1-\2-\3-\4-/'
}

# Send a notification (cross-platform)
send_notification() {
    local title="$1"
    local message="$2"

    # Try Python script (most portable)
    if command -v python3 &> /dev/null && [ -f "$LIB_DIR/notify.py" ]; then
        python3 "$LIB_DIR/notify.py" "$title" "$message" 2>/dev/null
        return 0
    fi

    # Platform-specific fallbacks
    local os_type="$(uname -s)"

    case "$os_type" in
        Darwin*)
            # macOS
            osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null
            ;;
        Linux*)
            # Linux
            if command -v notify-send &> /dev/null; then
                notify-send "$title" "$message" 2>/dev/null
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            # Windows (Git Bash, MSYS2, Cygwin)
            if command -v powershell &> /dev/null; then
                powershell -Command "New-BurntToastNotification -Text '$title', '$message'" 2>/dev/null
            fi
            ;;
    esac
}

# Detect operating system
detect_os() {
    local os_type="$(uname -s)"

    case "$os_type" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check if running in CI environment
is_ci() {
    [ -n "$CI" ] || [ -n "$CONTINUOUS_INTEGRATION" ] || [ -n "$GITHUB_ACTIONS" ] || [ -n "$GITLAB_CI" ]
}
