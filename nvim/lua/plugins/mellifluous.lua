return {
  "ramojus/mellifluous.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("mellifluous").setup({
      mellifluous = {
        neutral = true,
        bg_contrast = "hard",
      },
      dim_inactive = false,
      color_set = "mellifluous",
      styles = { -- see :h attr-list for options. set {} for NONE, { option = true } for option
        comments = { italic = true },
        conditionals = {},
        folds = {},
        loops = {},
        functions = { italic = true },
        keywords = { italic = true, bold = true },
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
        nvim_tree = {
          enabled = true,
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
