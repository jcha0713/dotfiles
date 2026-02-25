#!/usr/bin/env bash
# verify-structure.sh - Check if documented paths exist in the actual repo

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel)"

cd "$DOTFILES_DIR"

ERRORS=0

echo "🔍 Verifying dotfiles structure..."
echo ""

# Check entry points
check_file() {
    if [ -f "$1" ]; then
        echo "✓ $1"
    else
        echo "✗ $1 (NOT FOUND)"
        ((ERRORS++))
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo "✓ $1/"
    else
        echo "✗ $1/ (NOT FOUND)"
        ((ERRORS++))
    fi
}

echo "Entry Points:"
check_file "flake.nix"
check_file "home/common.nix"
check_file "home/nixos.nix"
check_file "home/darwin.nix"
check_dir "hosts/think"
check_dir "hosts/mini"

echo ""
echo "Config Directories:"
check_dir "config/nvim"
check_dir "config/zellij"
check_dir "config/wezterm"
check_dir "config/niri"
check_dir "config/waybar"
check_dir "config/ghostty"
check_dir "config/aerospace"
check_dir "config/karabiner"
check_dir "config/hammerspoon"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✅ All documented paths verified!"
    exit 0
else
    echo "⚠️  $ERRORS path(s) not found. Update SKILL.md or references."
    exit 1
fi
