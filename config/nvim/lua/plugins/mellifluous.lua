return {
  "ramojus/mellifluous.nvim",
  lazy = false,
  enabled = true,
  priority = 1000,
  config = function()
    require("mellifluous").setup({
      mellifluous = {
        neutral = true,
        -- bg_contrast = "hard",
        bg_contrast = "soft",
        highlight_overrides = {
          dark = function(highlighter, colors)
            highlighter.set("WinBarNC", {
              fg = colors.fg:darkened(50),
              bg = colors.bg,
            })

            highlighter.set("NuiComponentsSelectOptionSelected", {
              fg = colors.red,
            })

            highlighter.set("NuiComponentsSelectSeparator", {
              fg = colors.yellow,
            })

            highlighter.set("ColorColumn", {
              bg = colors.bg:lightened(5),
            })

            highlighter.set("LualineNormalPrimary", {
              bg = colors.purple,
              fg = colors.fg:darkened(100),
            })

            highlighter.set("LualineNormalSecondary", {
              bg = colors.bg:lightened(10),
              fg = colors.fg,
            })

            highlighter.set("LualineInsert", {
              bg = colors.blue,
              fg = colors.fg:darkened(100),
            })

            highlighter.set("LualineVisual", {
              bg = colors.green,
              fg = colors.fg:darkened(100),
            })

            highlighter.set("LualineReplace", {
              bg = colors.red,
              fg = colors.fg:darkened(100),
            })

            highlighter.set("LspSignatureActiveParameter", {
              bg = colors.red,
              fg = colors.fg:darkened(100),
            })

            highlighter.set("CursorLine", {
              bg = colors.bg:lightened(5),
            })
          end,
        },
      },
      dim_inactive = false,
      color_set = "mellifluous",
      styles = { -- see :h attr-list for options. set {} for NONE, { option = true } for option
        comments = { italic = true },
        conditionals = {},
        folds = {},
        loops = {},
        functions = { bold = true },
        keywords = { bold = true },
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      transparent_background = {
        enabled = false,
        floating_windows = true,
        telescope = true,
        file_tree = true,
        cursor_line = true,
        status_line = false,
      },
      flat_background = {
        line_numbers = true,
        floating_windows = true,
        file_tree = false,
        cursor_line_number = true,
      },
      plugins = {
        cmp = true,
        gitsigns = true,
        semantic_tokens = true,
        nvim_tree = {
          enabled = false,
          show_root = true,
        },
        telescope = {
          enabled = true,
        },
        startify = true,
      },
    })
    vim.cmd.colorscheme("mellifluous")
  end,
}
