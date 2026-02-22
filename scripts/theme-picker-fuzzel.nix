{ pkgs }:

pkgs.writeShellApplication {
  name = "theme-picker-fuzzel";
  runtimeInputs = with pkgs; [ fuzzel jq glib gnused systemd libnotify ];
  text = ''
    DOTFILES_DIR="$HOME/dotfiles"
    NIXOS_CONFIG="$DOTFILES_DIR/home/nixos.nix"
    GHOSTTY_CONFIG="$DOTFILES_DIR/config/ghostty/config"
    PI_SETTINGS="$HOME/.pi/agent/settings.json"
    PALETTES_FILE="$DOTFILES_DIR/lib/themes/palettes.nix"

    # Check if dotfiles repo exists
    if [ ! -d "$DOTFILES_DIR" ]; then
      notify-send "Theme Picker" "Error: Dotfiles directory not found" --urgency=critical
      exit 1
    fi

    # Get list of available themes from palettes.nix
    themes=$(grep -E '^[[:space:]]+[a-z0-9-]+[[:space:]]*=[[:space:]]*\{' "$PALETTES_FILE" | \
             grep -v 'colors' | \
             sed 's/^[[:space:]]*//; s/[[:space:]]*=.*//' | \
             sort -u)

    if [ -z "$themes" ]; then
      notify-send "Theme Picker" "Error: No themes found" --urgency=critical
      exit 1
    fi

    # Get current theme from nixos.nix
    current_theme=$(grep -E 'activeThemeName[[:space:]]*=[[:space:]]*"' "$NIXOS_CONFIG" | head -1 | sed 's/.*=[[:space:]]*"\([^"]*\)".*/\1/')

    # Show picker with fuzzel
    selected=$(printf '%s\n' "$themes" | \
      fuzzel --dmenu \
             --prompt "Theme ($current_theme): " \
             --width 30 \
             --lines 10)

    if [ -z "$selected" ]; then
      exit 0
    fi

    if [ "$selected" = "$current_theme" ]; then
      notify-send "Theme Picker" "'$selected' is already active"
      exit 0
    fi

    # Update activeThemeName in nixos.nix (for Waybar, Swaylock, etc.)
    sed -i "s/activeThemeName = \"[^\"]*\";/activeThemeName = \"$selected\";/" "$NIXOS_CONFIG"

    # Update Ghostty config
    if [ -f "$GHOSTTY_CONFIG" ]; then
      if grep -q "^theme = " "$GHOSTTY_CONFIG"; then
        sed -i "s/^theme = .*/theme = $selected/" "$GHOSTTY_CONFIG"
      else
        sed -i "/^shell-integration-features/a\\theme = $selected" "$GHOSTTY_CONFIG"
      fi
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

    # Update pi settings.json
    if [ -f "$PI_SETTINGS" ]; then
      jq ".theme = \"$COLOR_SCHEME\"" "$PI_SETTINGS" > "$PI_SETTINGS.tmp" && mv "$PI_SETTINGS.tmp" "$PI_SETTINGS"
    fi

    # Run switch to apply Nix configuration (requires terminal for sudo password)
    # Using a terminal to run switch so sudo password can be entered
    notify-send "Theme Picker" "Building with 'switch'..." --urgency=low
    
    # Open a terminal to run the rebuild (so user can enter sudo password)
    # After switch completes, services will be restarted
    cat > /tmp/theme-switch.sh << 'SCRIPT'
      #!/bin/bash
      cd ~/dotfiles && sudo nixos-rebuild switch --flake .#think 2>&1
      
      if [ $? -eq 0 ]; then
        # Restart services
        systemctl --user restart waybar 2>/dev/null
        systemctl --user restart mako 2>/dev/null
        notify-send "Theme Picker" "✓ '$selected' applied! Reload Ghostty."
      else
        notify-send "Theme Picker" "✗ Switch failed. Check terminal." --urgency=critical
      fi
      
      echo ""
      echo "Press Enter to close..."
      read
    SCRIPT
    chmod +x /tmp/theme-switch.sh
    
    # Run in ghostty
    ghostty -e /tmp/theme-switch.sh
  '';
}
