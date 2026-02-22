{ pkgs }:

pkgs.writeShellApplication {
  name = "theme-picker-fuzzel";
  runtimeInputs = with pkgs; [ fuzzel jq glib gnused systemd ];
  text = ''
    DOTFILES_DIR="$HOME/dotfiles"
    NIXOS_CONFIG="$DOTFILES_DIR/home/nixos.nix"
    GHOSTTY_CONFIG="$DOTFILES_DIR/config/ghostty/config"
    PI_SETTINGS="$HOME/.pi/agent/settings.json"
    PALETTES_FILE="$DOTFILES_DIR/lib/themes/palettes.nix"

    # Check if dotfiles repo exists
    if [ ! -d "$DOTFILES_DIR" ]; then
      notify-send "Theme Picker" "Error: Dotfiles directory not found"
      exit 1
    fi

    # Get list of available themes from palettes.nix
    themes=$(grep -E '^[[:space:]]+[a-z0-9-]+[[:space:]]*=[[:space:]]*\{' "$PALETTES_FILE" | \
             grep -v 'colors' | \
             sed 's/^[[:space:]]*//; s/[[:space:]]*=.*//' | \
             sort -u)

    if [ -z "$themes" ]; then
      notify-send "Theme Picker" "Error: No themes found"
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

    # Notify user to run switch
    notify-send "Theme Picker" "'$selected' selected. Run 'switch' to apply changes."
  '';
}
