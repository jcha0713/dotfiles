#!/usr/bin/env bash
# generate-structure.sh - Auto-generate structure documentation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR" && git rev-parse --show-toplevel)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
REF_FILE="$SKILL_DIR/references/structure.md"

cd "$DOTFILES_DIR"

echo "📝 Generating structure.md..."

cat > "$REF_FILE" << EOF
# Auto-Generated Dotfiles Structure

> Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
> Do not edit manually - run: \`./scripts/generate-structure.sh\`

## Repository Layout

\`\`\`
$(tree -L 3 -d --noreport -I 'result|.git' "$DOTFILES_DIR" 2>/dev/null || find "$DOTFILES_DIR" -maxdepth 3 -type d | sed 's|'$DOTFILES_DIR'/||' | sort)
\`\`\`

## Entry Points

### Flake Outputs
$(grep -E "^(nixos|darwin)Configurations\." flake.nix 2>/dev/null | sed 's/ =.*/"/' | sed 's/^/- /' || echo "- (run from dotfiles root to see outputs)")

### Home Configurations
$(ls -1 home/*.nix 2>/dev/null | xargs -n1 basename | sed 's/.nix//' | sed 's/^/- /' || echo "- (no home configs found)")

### System Configurations
$(for host in hosts/*/; do echo "- $(basename "$host")"; done 2>/dev/null || echo "- (no hosts found)")

## Config Directories

**Shared (both platforms):**
$(for dir in nvim zellij wezterm zsh; do [ -d "config/$dir" ] && echo "- config/$dir/"; done)

**NixOS only:**
$(for dir in niri waybar ghostty mako swaylock kime; do [ -d "config/$dir" ] && echo "- config/$dir/"; done)

**macOS only:**
$(for dir in aerospace karabiner hammerspoon espanso sprinkles; do [ -d "config/$dir" ] && echo "- config/$dir/"; done)
EOF

echo "✅ Generated: $REF_FILE"
