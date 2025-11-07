#!/bin/bash
# Configuration File Parser
# Reads optional .husky/config.json and provides defaults

# Get the directory where .husky is located
HUSKY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$HUSKY_DIR/config/config.json"

# Get configuration value with fallback to default
get_config() {
    local key="$1"
    local default="$2"

    # If config file doesn't exist, return default
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "$default"
        return 0
    fi

    # Try to parse JSON using python (most portable)
    if command -v python3 &> /dev/null; then
        local value=$(python3 -c "
import json, sys
try:
    with open('$CONFIG_FILE') as f:
        config = json.load(f)
    keys = '$key'.split('.')
    value = config
    for k in keys:
        value = value.get(k, None)
        if value is None:
            break
    print(value if value is not None else '$default')
except:
    print('$default')
" 2>/dev/null)
        echo "$value"
        return 0
    fi

    # Fallback: simple grep-based parsing (limited)
    if grep -q "\"$key\"" "$CONFIG_FILE" 2>/dev/null; then
        local value=$(grep "\"$key\"" "$CONFIG_FILE" | sed -E 's/.*"'$key'"[[:space:]]*:[[:space:]]*"?([^",}]+)"?.*/\1/')
        echo "$value"
    else
        echo "$default"
    fi
}

# Check if a feature is enabled
is_enabled() {
    local feature="$1"
    local value=$(get_config "enabled.$feature" "true")

    [ "$value" = "true" ] || [ "$value" = "True" ] || [ "$value" = "1" ]
}

# Get logs directory
get_logs_dir() {
    get_config "logs.directory" ".rimthan_cli"
}

# Get Claude model
get_claude_model() {
    get_config "claude.model" "sonnet"
}

# Get Claude max turns
get_claude_max_turns() {
    get_config "claude.maxTurns" "15"
}

# Check if auto-update is enabled
is_auto_update_enabled() {
    local value=$(get_config "claude.enableAutoUpdate" "true")
    [ "$value" = "true" ] || [ "$value" = "True" ] || [ "$value" = "1" ]
}

# Get auto-detection mode
is_auto_detection_enabled() {
    local value=$(get_config "detection.auto" "true")
    [ "$value" = "true" ] || [ "$value" = "True" ] || [ "$value" = "1" ]
}
