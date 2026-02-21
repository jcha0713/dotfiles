# Centralized theme management for all applications
# Usage in home configuration:
#
#   imports = [ ./lib/themes ];
#   
#   themes.active = "e-ink-night";  # Set your active theme
#

{ config, pkgs, lib, ... }:

let
  # Import all color palettes
  palettes = import ./palettes.nix;

  # Get the active theme configuration
  activeTheme = palettes.${cfg.active} or palettes.e-ink;

  # Configuration options
  cfg = config.themes;

in
{
  options.themes = {
    active = lib.mkOption {
      type = lib.types.str;
      default = "e-ink";
      description = "The active color theme name";
    };

    palettes = lib.mkOption {
      type = lib.types.attrs;
      default = palettes;
      readOnly = true;
      description = "All available color palettes";
    };

    colors = lib.mkOption {
      type = lib.types.attrs;
      default = activeTheme.colors;
      readOnly = true;
      description = "Colors of the active theme";
    };

    variant = lib.mkOption {
      type = lib.types.str;
      default = activeTheme.variant;
      readOnly = true;
      description = "Variant of the active theme (light or dark)";
    };
  };

  # Example: Generate Ghostty themes
  config = lib.mkIf cfg.enable {
    # Install generated theme files
    home.packages = [
      # Ghostty themes (generated from palettes)
      (import ./ghostty.nix { inherit pkgs palettes; })
      
      # Neovim themes (generated from palettes)  
      (import ./neovim.nix { inherit pkgs palettes; })
    ];
  };
}
