return {
  "ramojus/mellifluous.nvim",
  lazy = false,
  enabled = false,
  priority = 1000,
  config = function()
    require("mellifluous").setup({
      mellifluous = {
        neutral = true,
        -- bg_contrast = "hard",
        bg_contrast = "soft",
        color_overrides = {
          dark = {
            comments = "#525252",
            -- bg = "#1e1e1e",
            -- https://gogh-co.github.io/Gogh/ - Arthur
            red = "#CC5533",
            yellow = "#FFA75D",
            green = "#88AA22",
            cyan = "#6495ED",
          },
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
