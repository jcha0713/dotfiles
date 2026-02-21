# Generate Neovim Lua colorscheme from centralized palettes

{ pkgs, palettes }:

let
  # Function to generate a Neovim colorscheme file from a palette
  generateNeovimTheme = name: palette:
    let
      c = palette.colors;
      isDark = palette.variant == "dark";
    in
    pkgs.writeTextFile {
      name = "neovim-theme-${name}";
      destination = "/share/nvim/site/pack/themes/start/${name}/colors/${name}.lua";
      text = ''
        -- ${palette.name} colorscheme for Neovim
        -- Generated from centralized Nix palette
        -- ${if isDark then "Dark" else "Light"} variant

        vim.g.colors_name = "${name}"

        local colors = {
          bg = "${c.bg}",
          fg = "${c.fg}",
          cursor = "${c.cursor}",
          cursor_text = "${c.cursor-text}",
          selection_bg = "${c.selection-bg}",
          selection_fg = "${c.selection-fg}",
          
          black = "${c.black}",
          red = "${c.red}",
          green = "${c.green}",
          yellow = "${c.yellow}",
          blue = "${c.blue}",
          magenta = "${c.magenta}",
          cyan = "${c.cyan}",
          white = "${c.white}",
          
          bright_black = "${c.bright-black}",
          bright_red = "${c.bright-red}",
          bright_green = "${c.bright-green}",
          bright_yellow = "${c.bright-yellow}",
          bright_blue = "${c.bright-blue}",
          bright_magenta = "${c.bright-magenta}",
          bright_cyan = "${c.bright-cyan}",
          bright_white = "${c.bright-white}",
        }

        -- Apply highlight groups
        local function set_hl(group, opts)
          vim.api.nvim_set_hl(0, group, opts)
        end

        -- Editor
        set_hl("Normal", { bg = colors.bg, fg = colors.fg })
        set_hl("Cursor", { bg = colors.cursor, fg = colors.cursor_text })
        set_hl("Visual", { bg = colors.selection_bg, fg = colors.selection_fg })
        set_hl("LineNr", { fg = colors.bright_black })
        set_hl("CursorLineNr", { fg = colors.fg, bold = true })
        
        -- Syntax
        set_hl("Comment", { fg = colors.bright_black, italic = true })
        set_hl("Keyword", { fg = colors.fg, bold = true })
        set_hl("String", { fg = colors.bright_green })
        set_hl("Function", { fg = colors.bright_blue })
        set_hl("Number", { fg = colors.bright_yellow })
        set_hl("Type", { fg = colors.bright_cyan })
        
        -- UI
        set_hl("StatusLine", { bg = colors.selection_bg, fg = colors.fg })
        set_hl("StatusLineNC", { bg = colors.bg, fg = colors.bright_black })
        set_hl("Pmenu", { bg = colors.selection_bg, fg = colors.fg })
        set_hl("PmenuSel", { bg = colors.cursor, fg = colors.cursor_text })
      '';
    };

  # Generate all theme files
  themeFiles = pkgs.symlinkJoin {
    name = "neovim-eink-themes";
    paths = pkgs.lib.mapAttrsToList generateNeovimTheme palettes;
  };

in
  themeFiles
