# Centralized color palettes for all applications
# Each theme exports colors that can be used by Ghostty, Neovim, and other apps

{
  # E-ink Light - Paper white background with ink text
  e-ink = {
    name = "e-ink";
    variant = "light";
    colors = {
      bg = "#e0dcd4";
      fg = "#1a1a1a";
      cursor = "#1a1a1a";
      cursor-text = "#e0dcd4";
      selection-bg = "#d9d5cd";
      selection-fg = "#1a1a1a";
      
      # ANSI colors (normal 0-7, bright 8-15)
      black = "#1a1a1a";
      red = "#404040";
      green = "#595959";
      yellow = "#808080";
      blue = "#999999";
      magenta = "#b3b3b3";
      cyan = "#cccccc";
      white = "#e0dcd4";
      
      bright-black = "#333333";
      bright-red = "#666666";
      bright-green = "#808080";
      bright-yellow = "#a6a6a6";
      bright-blue = "#bfbfbf";
      bright-magenta = "#d9d5cd";
      bright-cyan = "#f0ece4";
      bright-white = "#ffffff";
    };
  };

  # E-ink Dark - High contrast dark
  e-ink-dark = {
    name = "e-ink-dark";
    variant = "dark";
    colors = {
      bg = "#0d0d0d";
      fg = "#f5f2ed";
      cursor = "#f5f2ed";
      cursor-text = "#0d0d0d";
      selection-bg = "#333333";
      selection-fg = "#ffffff";
      
      black = "#f5f2ed";
      red = "#e0dcd4";
      green = "#c0c0c0";
      yellow = "#a0a0a0";
      blue = "#808080";
      magenta = "#606060";
      cyan = "#404040";
      white = "#0d0d0d";
      
      bright-black = "#ffffff";
      bright-red = "#f0f0f0";
      bright-green = "#e8e8e8";
      bright-yellow = "#d0d0d0";
      bright-blue = "#505050";
      bright-magenta = "#303030";
      bright-cyan = "#1a1a1a";
      bright-white = "#000000";
    };
  };

  # E-ink Sepia - Warm paper tones
  e-ink-sepia = {
    name = "e-ink-sepia";
    variant = "light";
    colors = {
      bg = "#f4ecd8";
      fg = "#3d3229";
      cursor = "#3d3229";
      cursor-text = "#f4ecd8";
      selection-bg = "#e6d9c0";
      selection-fg = "#3d3229";
      
      black = "#3d3229";
      red = "#5c4d3c";
      green = "#7a6650";
      yellow = "#998066";
      blue = "#b8997d";
      magenta = "#d1b899";
      cyan = "#e6d9c0";
      white = "#f4ecd8";
      
      bright-black = "#2a231c";
      bright-red = "#4a3d30";
      bright-green = "#6b5945";
      bright-yellow = "#8f7a60";
      bright-blue = "#b8a080";
      bright-magenta = "#dccbb0";
      bright-cyan = "#f0e6d0";
      bright-white = "#faf6ed";
    };
  };

  # E-ink Night - Amber for night reading
  e-ink-night = {
    name = "e-ink-night";
    variant = "dark";
    colors = {
      bg = "#0a0805";
      fg = "#ffaa00";
      cursor = "#ffaa00";
      cursor-text = "#0a0805";
      selection-bg = "#5c451c";
      selection-fg = "#ffcc66";
      
      black = "#ffcc00";
      red = "#e6b800";
      green = "#cca300";
      yellow = "#b38f00";
      blue = "#997a00";
      magenta = "#806600";
      cyan = "#665200";
      white = "#0a0805";
      
      bright-black = "#ffcc66";
      bright-red = "#ffdd88";
      bright-green = "#ffeeaa";
      bright-yellow = "#fff5cc";
      bright-blue = "#664422";
      bright-magenta = "#4d3319";
      bright-cyan = "#332b1a";
      bright-white = "#000000";
    };
  };
}
