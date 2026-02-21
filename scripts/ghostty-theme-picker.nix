{ pkgs }:

pkgs.writeShellApplication {
  name = "ghostty-theme-picker";
  runtimeInputs = with pkgs; [ fzf gnused coreutils glib jq ];
  text = ''
    # Edit the source file in dotfiles repo, not the symlink
    DOTFILES_DIR="$HOME/dotfiles"
    GHOSTTY_CONFIG="$DOTFILES_DIR/config/ghostty/config"
    THEMES_DIR="$HOME/.config/ghostty/themes"
    PI_SETTINGS="$HOME/.pi/agent/settings.json"

    # Check if dotfiles repo exists
    if [ ! -d "$DOTFILES_DIR" ]; then
      echo "Error: Dotfiles directory not found at $DOTFILES_DIR"
      exit 1
    fi

    # Check if themes directory exists
    if [ ! -d "$THEMES_DIR" ]; then
      echo "Error: Ghostty themes directory not found at $THEMES_DIR"
      exit 1
    fi

    # Get list of available themes
    # Use -L to follow symlinks (themes dir is a symlink to nix store)
    themes=$(find -L "$THEMES_DIR" -maxdepth 1 -type f -exec basename {} \; 2>/dev/null | sort)

    if [ -z "$themes" ]; then
      echo "Error: No themes found in $THEMES_DIR"
      exit 1
    fi

    # Show picker with fzf
    selected=$(echo "$themes" | fzf --prompt="Select Ghostty theme: " \
      --height=40% \
      --reverse \
      --preview="echo 'Preview: {}'" \
      --preview-window=up:1)

    if [ -z "$selected" ]; then
      echo "No theme selected."
      exit 0
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

    # Update the config file in dotfiles repo
    if [ -f "$GHOSTTY_CONFIG" ]; then
      # Check if theme line exists
      if grep -q "^theme = " "$GHOSTTY_CONFIG"; then
        # Replace existing theme line
        sed -i "s/^theme = .*/theme = $selected/" "$GHOSTTY_CONFIG"
      else
        # Add theme line after shell-integration-features line
        sed -i "/^shell-integration-features/a\\theme = $selected" "$GHOSTTY_CONFIG"
      fi
      echo "✓ Ghostty theme: $selected"
    else
      echo "Error: Ghostty config not found at $GHOSTTY_CONFIG"
      exit 1
    fi

    # Update GNOME color scheme
    gsettings set org.gnome.desktop.interface color-scheme "prefer-$COLOR_SCHEME"
    echo "✓ GNOME color-scheme: prefer-$COLOR_SCHEME"

    # Update pi settings.json
    if [ -f "$PI_SETTINGS" ]; then
      jq ".theme = \"$COLOR_SCHEME\"" "$PI_SETTINGS" > "$PI_SETTINGS.tmp" && mv "$PI_SETTINGS.tmp" "$PI_SETTINGS"
      echo "✓ Pi theme: $COLOR_SCHEME"
    else
      echo "⚠ Pi settings not found at $PI_SETTINGS (skipped)"
    fi

    echo ""
    echo "Run 'switch' to apply Ghostty changes, then reload Ghostty (Ctrl+Shift+Comma)."
  '';
}
