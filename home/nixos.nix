{ config, pkgs, dotfilesPath, ... }:

let
  # Import theme palettes
  palettes = import ../lib/themes/palettes.nix;
  
  # Default theme - change this to switch themes, or use the theme-picker script
  activeThemeName = "e-ink-sepia";  # Options: e-ink, e-ink-dark, e-ink-sepia, e-ink-night
  activeTheme = palettes.${activeThemeName};
  c = activeTheme.colors;
in
{
  imports = [
    ./common.nix
    ./zsh.nix
  ];

  home.username = "joohoon";
  home.homeDirectory = "/home/joohoon";
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # NixOS-specific zsh additions
  programs.zsh.shellAliases = {
    switch = "cd ~/dotfiles && sudo nixos-rebuild switch --flake .#think";
    nix-switch = "cd ~/dotfiles && sudo nixos-rebuild switch --flake .#think";
  };

  # Symlink dotfiles from the repo
  home.file = {
    ".pi/agent/keybindings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/pi/agent/keybindings.json";
    ".pi/agent/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/pi/agent/settings.json";
    ".pi/agent/skills".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/pi/agent/skills";

    # NixOS-specific
    ".config/niri/config.kdl".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/niri/config.kdl";
    
    # Waybar - config is symlinked, style.css is generated from theme
    ".config/waybar/config".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/waybar/config";
    
    # Waybar style generated from active theme
    ".config/waybar/style.css".text = ''
      /* Generated from ${activeThemeName} theme */
      * { 
        font-family: monospace; 
        font-size: 13px; 
      }
      
      window#waybar { 
        background-color: ${c.bg}; 
        color: ${c.fg}; 
      }
      
      #workspaces button { 
        padding: 0 10px; 
        color: ${c.fg};
      }
      
      #workspaces button.focused { 
        background-color: ${c.blue}; 
        color: ${c.bg}; 
      }
      
      #workspaces button.urgent {
        background-color: ${c.red};
        color: ${c.bg};
      }
      
      #clock, #battery, #cpu, #memory, #disk, #temperature,
      #backlight, #network, #pulseaudio, #tray {
        padding: 0 10px;
        margin: 0 4px;
        color: ${c.fg};
      }
      
      #battery.charging { color: ${c.green}; }
      #battery.critical:not(.charging) { color: ${c.red}; }
      #pulseaudio.muted { color: ${c.bright-black}; }
      
      tooltip {
        background: ${c.selection-bg};
        color: ${c.selection-fg};
        border: 1px solid ${c.bright-black};
      }
    '';
    
    # Swaylock - generate config with theme colors
    ".config/swaylock/config".text = ''
      # Generated from ${activeThemeName} theme
      color=${c.bg}
      bs-hl-color=${c.red}
      key-hl-color=${c.green}
      line-color=${c.blue}
      ring-color=${c.fg}
      inside-color=${c.bg}
      separator-color=${c.bright-black}
    '';
    
    # Shared with Mac Mini
    ".config/nvim".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/nvim";
    ".config/wezterm".source = 
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/wezterm";
    
    # Kime Korean IME config
    ".config/kime/config.yaml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/kime/config.yaml";
    
    # Ghostty config and themes
    ".config/ghostty/config".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/ghostty/config";
    ".config/ghostty/themes".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/ghostty/themes";
    
    # Zellij config
    ".config/zellij/config.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/zellij/config.kdl";
  };

  # User packages (NixOS-specific, mostly Wayland related)
  home.packages = with pkgs; [
    swaylock-effects
    swayidle
    mako
    brightnessctl
    libnotify
    swaybg
    # Clipboard management for Wayland
    cliphist  # Clipboard history with fzf integration
    unzip
    trash-cli
    # Theme picker (fuzzel GUI)
    (import ../scripts/theme-picker-fuzzel.nix { inherit pkgs; })
  ];

  # Clipboard history service - saves clipboard to history
  services.cliphist.enable = true;
}
