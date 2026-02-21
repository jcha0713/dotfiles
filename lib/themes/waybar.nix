# Waybar configuration using centralized theme colors
# This module generates waybar style.css from the active theme

{ config, pkgs, lib, dotfilesPath, ... }:

let
  # Import palettes
  palettes = import ./palettes.nix;
  
  # Set active theme (this could come from config.themes.active)
  activeThemeName = "e-ink-night";  # or config.themes.active
  activeTheme = palettes.${activeThemeName};
  c = activeTheme.colors;
in
{
  # Method 1: Generate style.css entirely in Nix with theme colors
  home.file.".config/waybar/style.css".text = ''
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
    
    #clock,
    #battery,
    #cpu,
    #memory,
    #disk,
    #temperature,
    #backlight,
    #network,
    #pulseaudio,
    #tray {
      padding: 0 10px;
      margin: 0 4px;
      color: ${c.fg};
    }
    
    #battery.charging {
      color: ${c.green};
    }
    
    #battery.critical:not(.charging) {
      color: ${c.red};
    }
    
    #pulseaudio.muted {
      color: ${c.bright-black};
    }
    
    tooltip {
      background: ${c.selection-bg};
      color: ${c.selection-fg};
      border: 1px solid ${c.bright-black};
    }
  '';

  # Method 2: Keep config as symlink but inject CSS variables
  # home.file.".config/waybar/colors.css".text = ''
  #   :root {
  #     --bg: ${c.bg};
  #     --fg: ${c.fg};
  #     --accent: ${c.blue};
  #     --urgent: ${c.red};
  #     --success: ${c.green};
  #   }
  # '';
  # Then in your style.css (symlinked), use: background-color: var(--bg);
  
  # Keep the config as symlink
  home.file.".config/waybar/config".source = 
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/waybar/config";
}
