# Example: How to use centralized themes in your home configuration

{ config, pkgs, lib, dotfilesPath, ... }:

let
  # Import palettes
  palettes = import ../lib/themes/palettes.nix;
  
  # Set your active theme here
  activeThemeName = "e-ink-night";
  activeTheme = palettes.${activeThemeName};
  colors = activeTheme.colors;

in
{
  # Example 1: Use colors in program configs
  programs.fzf.defaultOptions = with colors; ''
    --color=fg:${fg},bg:${bg},hl:${yellow},fg+:${fg},bg+:${selection-bg}
  '';

  # Example 2: Generate bat theme from colors
  programs.bat.config.theme = "base16";

  # Example 3: Zsh syntax highlighting using theme colors
  programs.zsh.initExtra = with colors; ''
    export ZSH_HIGHLIGHT_STYLES=
      default=${fg},
      unknown-token=${red},
      reserved-word=${yellow},
      alias=${green},
      builtin=${cyan},
      function=${blue},
      command=${fg}
  '';

  # Example 4: Set active theme for Ghostty
  # The ghostty config would reference these colors
  home.file.".config/ghostty/config".text = with colors; ''
    theme = ${activeThemeName}
    
    # Or set colors directly:
    background = ${bg}
    foreground = ${fg}
    cursor-color = ${cursor}
  '';

  # Example 5: Generate tool configs dynamically
  home.file.".config/waybar/colors.css".text = with colors; ''
    @define-color bg ${bg};
    @define-color fg ${fg};
    @define-color accent ${blue};
  '';
}
