# Generate Ghostty theme files from centralized palettes

{ pkgs, palettes }:

let
  # Function to generate a Ghostty theme file from a palette
  generateGhosttyTheme = name: palette: 
    let
      c = palette.colors;
    in
    pkgs.writeTextFile {
      name = "ghostty-theme-${name}";
      destination = "/share/ghostty/themes/${name}";
      text = ''
        # ${palette.name} Theme
        # Generated from centralized Nix palette
        # ${if palette.variant == "dark" then "Dark" else "Light"} variant

        background = ${c.bg}
        foreground = ${c.fg}

        cursor-color = ${c.cursor}
        cursor-text = ${c.cursor-text}

        selection-background = ${c.selection-bg}
        selection-foreground = ${c.selection-fg}

        # Normal colors
        palette = 0=${c.black}
        palette = 1=${c.red}
        palette = 2=${c.green}
        palette = 3=${c.yellow}
        palette = 4=${c.blue}
        palette = 5=${c.magenta}
        palette = 6=${c.cyan}
        palette = 7=${c.white}

        # Bright colors
        palette = 8=${c.bright-black}
        palette = 9=${c.bright-red}
        palette = 10=${c.bright-green}
        palette = 11=${c.bright-yellow}
        palette = 12=${c.bright-blue}
        palette = 13=${c.bright-magenta}
        palette = 14=${c.bright-cyan}
        palette = 15=${c.bright-white}
      '';
    };

  # Generate all theme files
  themeFiles = pkgs.symlinkJoin {
    name = "ghostty-eink-themes";
    paths = pkgs.lib.mapAttrsToList generateGhosttyTheme palettes;
  };

in
  themeFiles
