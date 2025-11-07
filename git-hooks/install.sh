#!/bin/bash
# Universal Hooks Installation Script
# Sets up Rimthan's universal Git hooks in any repository

set -e

echo "🎣 Installing Rimthan Universal Git Hooks..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not a git repository"
    echo "   Run 'git init' first"
    exit 1
fi

# Check if Husky is installed
if ! command -v husky &> /dev/null; then
    echo "⚠️  Husky not found. Attempting to install..."

    # Detect package manager
    if [ -f "package.json" ]; then
        if [ -f "bun.lockb" ]; then
            echo "   Installing with bun..."
            bun add -D husky
        elif [ -f "pnpm-lock.yaml" ]; then
            echo "   Installing with pnpm..."
            pnpm add -D husky
        elif [ -f "yarn.lock" ]; then
            echo "   Installing with yarn..."
            yarn add -D husky
        else
            echo "   Installing with npm..."
            npm install -D husky
        fi

        # Initialize Husky
        npx husky init
    else
        echo "❌ Error: package.json not found"
        echo "   For JavaScript/TypeScript projects, create package.json first"
        echo "   For other languages, install Husky manually or skip this step"
        exit 1
    fi
fi

# Create .husky directory if it doesn't exist
mkdir -p "$REPO_ROOT/.husky"

# Copy hook files if we're in the VoiceAgent repo (source)
if [ -f "$SCRIPT_DIR/pre-commit" ] && [ -f "$SCRIPT_DIR/lib/detect-env.sh" ]; then
    echo "📦 Copying universal hooks from source..."

    # Copy hooks
    cp "$SCRIPT_DIR/pre-commit" "$REPO_ROOT/.husky/pre-commit"
    cp "$SCRIPT_DIR/pre-push" "$REPO_ROOT/.husky/pre-push"
    cp "$SCRIPT_DIR/post-commit" "$REPO_ROOT/.husky/post-commit"

    # Copy lib directory
    mkdir -p "$REPO_ROOT/.husky/lib"
    cp -r "$SCRIPT_DIR/lib/"* "$REPO_ROOT/.husky/lib/"

    # Copy scripts directory
    mkdir -p "$REPO_ROOT/.husky/scripts"
    cp -r "$SCRIPT_DIR/scripts/"* "$REPO_ROOT/.husky/scripts/"

    # Copy config directory and template
    mkdir -p "$REPO_ROOT/.husky/config"
    if [ ! -f "$REPO_ROOT/.husky/config/config.json" ]; then
        cp "$SCRIPT_DIR/config/config.json" "$REPO_ROOT/.husky/config/config.json"
        echo "📝 Created config/config.json (customize as needed)"
    fi
    if [ ! -f "$REPO_ROOT/.husky/config/config.example.json" ]; then
        cp "$SCRIPT_DIR/config/config.example.json" "$REPO_ROOT/.husky/config/config.example.json"
    fi

    # Make scripts executable
    chmod +x "$REPO_ROOT/.husky/pre-commit"
    chmod +x "$REPO_ROOT/.husky/pre-push"
    chmod +x "$REPO_ROOT/.husky/post-commit"
    chmod +x "$REPO_ROOT/.husky/lib/"*.sh
    chmod +x "$REPO_ROOT/.husky/lib/"*.py
    chmod +x "$REPO_ROOT/.husky/scripts/"*.sh

    echo "✅ Universal hooks installed!"
else
    echo "ℹ️  Hook files not found in current directory"
    echo "   This script should be run from .husky/ directory of VoiceAgent repo"
    echo "   Or copy .husky/ directory manually to target repository"
    exit 1
fi

# Add .rimthan_cli to .gitignore if not already there
if [ -f "$REPO_ROOT/.gitignore" ]; then
    if ! grep -q ".rimthan_cli" "$REPO_ROOT/.gitignore"; then
        echo "" >> "$REPO_ROOT/.gitignore"
        echo "# Claude CLI logs" >> "$REPO_ROOT/.gitignore"
        echo ".rimthan_cli/" >> "$REPO_ROOT/.gitignore"
        echo "📝 Added .rimthan_cli/ to .gitignore"
    fi
else
    echo "⚠️  .gitignore not found - create one and add .rimthan_cli/"
fi

# Detect tech stacks
echo ""
echo "🔍 Detecting tech stacks in repository..."
source "$REPO_ROOT/.husky/lib/detect-env.sh"
stacks=$(detect_stacks)

if [ -n "$stacks" ]; then
    echo "   Found: $(echo $stacks | tr '\n' ' ')"
else
    echo "   No recognized tech stacks detected yet"
    echo "   Hooks will auto-detect when you add project files"
fi

echo ""
echo "✨ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Review .husky/config/config.json and customize if needed"
echo "2. Read .husky/docs/README.md for complete documentation"
echo "3. Test hooks by making a commit"
echo "4. Check that pre-commit linting works"
echo "5. Check that post-commit CLAUDE.md analysis works"
echo ""
echo "For other tech stacks (Go/Dart/Python), ensure required tools are installed:"
echo "  - Go: go, golangci-lint"
echo "  - Dart/Flutter: dart, flutter"
echo "  - Python: pytest or unittest"
