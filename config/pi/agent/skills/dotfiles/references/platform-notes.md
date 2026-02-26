# Platform-Specific Notes

## NixOS (ThinkPad)

### Hardware Considerations
- **WiFi**: iwlwifi with power management disabled (suspend/resume fix)
- **Sleep**: Uses `deep` sleep for better battery
- **Resume**: Custom systemd service fixes network after resume

### Window Manager: Niri
- Scrollable tiling Wayland compositor
- Config: `config/niri/config.kdl`
- Key features:
  - Column-based layout (scroll through windows)
  - Touchpad gestures for workspace switching
  - Built-in screenshot utility

### Status Bar: Noctalia
- Config: `home/noctalia.nix` → `programs.noctalia-shell.settings`
- Provides: top bar, notifications, lock screen, launcher, screenshots
- Replaces: waybar, mako, swaylock, swaybg, swayidle
- Docs: https://docs.noctalia.dev

### Clipboard: cliphist
- History with fzf integration
- Service auto-starts via `services.cliphist.enable`
- Access: `cliphist list | fzf | cliphist decode | wl-copy`

### Rebuild Command
```bash
cd ~/dotfiles && sudo nixos-rebuild switch --flake .#think
```

### Available Aliases
```bash
switch      # cd ~/dotfiles && sudo nixos-rebuild switch --flake .#think
nix-switch  # Same as above
```

### Theme Picker
- Command: `theme-picker-fuzzel`
- Changes `activeThemeName` in `home/nixos.nix`
- Requires rebuild to apply fully

---

## macOS (Mac Mini)

### Window Manager: Aerospace
- i3-like tiling for macOS
- Config: `config/aerospace/aerospace.toml`
- Key features:
  - Workspace-based tiling
  - Compatible with native macOS spaces
  - Better than Yabai (no SIP disable needed)

### Keyboard: Karabiner-Elements
- Config: `config/karabiner/karabiner.json`
- Complex modifications for:
  - Caps Lock → Escape/Ctrl
  - Custom layer for symbols
  - App-specific bindings

### Automation: Hammerspoon
- Config: `config/hammerspoon/init.lua`
- Lua-based automation:
  - Window management helpers
  - Custom hotkeys
  - System integration

### Text Expansion: Espanso
- Config: `config/espanso/match/base.yml`
- Cross-app text replacement
- Matches synced via git

### Rebuild Command
```bash
cd ~/dotfiles && darwin-rebuild switch --flake .#mini
```

### Available Tools
- `colima` - Container runtime (Docker alternative)
- `mos` - Smooth scrolling
- `aldente` - Battery management
- `espanso` - Text expansion

### Path Differences
- Home directory: `/Users/jcha0713` (not `/home/joohoon`)
- Dotfiles path: `/Users/jcha0713/dotfiles`
- Username: `jcha0713` (not `joohoon`)

---

## Shared Between Platforms

### Neovim
- Config: `config/nvim/`
- Plugin manager: lazy.nvim
- Structure:
  - `init.lua` - Entry point
  - `lua/plugins/` - One file per plugin
  - `lua/config/` - Core configuration
  - `snippets/` - Language-specific snippets

### Zellij
- Config: `config/zellij/config.kdl`
- Terminal multiplexer (tmux alternative)
- KDL format (not YAML/TOML)

### WezTerm
- Config: `config/wezterm/wezterm.lua`
- Lua configuration
- Shared between platforms but can detect OS

### Git Configuration
- All git config in `home/common.nix`
- Delta for diff viewing
- Aliases: `st`, `l`, `undo`, `fomo`, etc.
- Delta themes fetched from GitHub

---

## Platform Detection in Scripts

```bash
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # NixOS
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
fi
```

Or in Nix:
```nix
pkgs.stdenv.isLinux   # true on NixOS
pkgs.stdenv.isDarwin  # true on macOS
```
