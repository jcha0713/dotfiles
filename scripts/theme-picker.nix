{ pkgs }:

pkgs.writeShellApplication {
  name = "theme-picker";
  runtimeInputs = with pkgs; [ fzf jq glib gnused systemd ];
  text = ''
    DOTFILES_DIR="$HOME/dotfiles"
    NIXOS_CONFIG="$DOTFILES_DIR/home/nixos.nix"
    GHOSTTY_CONFIG="$DOTFILES_DIR/config/ghostty/config"
    PI_SETTINGS="$HOME/.pi/agent/settings.json"
    PALETTES_FILE="$DOTFILES_DIR/lib/themes/palettes.nix"

    # Check if dotfiles repo exists
    if [ ! -d "$DOTFILES_DIR" ]; then
      echo "Error: Dotfiles directory not found at $DOTFILES_DIR"
      exit 1
    fi

    # Get list of available themes from palettes.nix
    themes=$(grep -E '^[[:space:]]+[a-z0-9-]+[[:space:]]*=[[:space:]]*\{' "$PALETTES_FILE" | \
             grep -v 'colors' | \
             sed 's/^[[:space:]]*//; s/[[:space:]]*=.*//' | \
             sort -u)

    if [ -z "$themes" ]; then
      echo "Error: No themes found in $PALETTES_FILE"
      exit 1
    fi

    # Get current theme from nixos.nix
    current_theme=$(grep -E 'activeThemeName[[:space:]]*=[[:space:]]*"' "$NIXOS_CONFIG" | head -1 | sed 's/.*=[[:space:]]*"\([^"]*\)".*/\1/')

    # Show picker with fzf
    selected=$(printf '%s\n' "$themes" | fzf --prompt="Select system theme: " \
      --height=40% \
      --reverse \
      --preview="echo 'Current: '$current_theme'
Selected: {}'" \
      --preview-window=up:2)

    if [ -z "$selected" ]; then
      echo "No theme selected."
      exit 0
    fi

    if [ "$selected" = "$current_theme" ]; then
      echo "Theme '$selected' is already active."
      exit 0
    fi

    # Update activeThemeName in nixos.nix (for Waybar, Swaylock, etc.)
    sed -i "s/activeThemeName = \"[^\"]*\";/activeThemeName = \"$selected\";/" "$NIXOS_CONFIG"
    echo "✓ NixOS config theme: $selected"

    # Update Ghostty config
    if [ -f "$GHOSTTY_CONFIG" ]; then
      if grep -q "^theme = " "$GHOSTTY_CONFIG"; then
        sed -i "s/^theme = .*/theme = $selected/" "$GHOSTTY_CONFIG"
      else
        sed -i "/^shell-integration-features/a\\theme = $selected" "$GHOSTTY_CONFIG"
      fi
      echo "✓ Ghostty theme: $selected"
    fi

    # Determine if dark or light theme
    case "$selected" in
      *-dark|*-night)
        COLOR_SCHEME="dark"
        ;;
      *)
        COLOR_SCHEME="light"
        ;;
    esac

    # Update GNOME color scheme
    gsettings set org.gnome.desktop.interface color-scheme "prefer-$COLOR_SCHEME"
    echo "✓ GNOME color-scheme: prefer-$COLOR_SCHEME"

    # Update pi settings.json
    if [ -f "$PI_SETTINGS" ]; then
      jq ".theme = \"$COLOR_SCHEME\"" "$PI_SETTINGS" > "$PI_SETTINGS.tmp" && mv "$PI_SETTINGS.tmp" "$PI_SETTINGS"
      echo "✓ Pi theme: $COLOR_SCHEME"
    else
      echo "⚠ Pi settings not found (skipped)"
    fi

    # Run switch to apply Nix configuration
    echo ""
    echo "Applying theme with 'switch'..."
    cd "$DOTFILES_DIR" && sudo nixos-rebuild switch --flake .#think

    # Restart services to apply theme changes
    echo ""
    echo "Restarting services..."
    
    # Restart Waybar to pick up new CSS
    if systemctl --user is-active --quiet waybar 2>/dev/null; then
      systemctl --user restart waybar
      echo "✓ Waybar restarted"
    fi
    
    # Send signal to Swaylock (if running) or just note it will apply on next lock
    if pgrep -x swaylock >/dev/null 2>&1; then
      echo "⚠ Swaylock is currently running, theme will apply on next lock"
    else
      echo "✓ Swaylock config updated (will apply on next lock)"
    fi
    
    # Restart mako (notification daemon) if using themed config
    if systemctl --user is-active --quiet mako 2>/dev/null; then
      systemctl --user restart mako
      echo "✓ Mako restarted"
    fi

    echo ""
    echo "✓ Theme '$selected' applied system-wide!"
    echo "Reload Ghostty (Ctrl+Shift+Comma) or restart to apply changes."
  '';
}
