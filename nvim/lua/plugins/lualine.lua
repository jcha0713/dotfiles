return {
  "nvim-lualine/lualine.nvim",
  event = "VimEnter",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
  },
  config = function()
    local lualine = require("lualine")

    local colors = {
      blue = "#80a0ff",
      cyan = "#79dac8",
      black = "#080808",
      white = "#c6c6c6",
      red = "#ff5189",
      violet = "#a9a1e1",
      grey = "#303030",
    }

    local bubbles_theme = {
      normal = {
        -- a = { fg = colors.black, bg = colors.violet },
        a = "LualineNormalPrimary",
        b = "LualineNormalSecondary",
        c = { fg = colors.white },
      },

      insert = { a = "LualineInsert" },
      visual = { a = "LualineVisual" },
      replace = { a = "LualineReplace" },

      inactive = {
        a = { fg = colors.white, bg = colors.black },
        b = { fg = colors.white, bg = colors.black },
        c = { fg = colors.white },
      },
    }

    lualine.setup({
      options = {
        icons_enabled = true,
        theme = bubbles_theme,
        component_separators = "",
        section_separators = { left = "", right = "" },
        always_divide_middle = true,
        globalstatus = true,
      },
      sections = {
        lualine_a = {
          { "mode", separator = { left = "" }, right_padding = 2 },
        },
        lualine_b = {
          "branch",
          "diff",
          { "diagnostics", sources = { "nvim_diagnostic" } },
        },
        lualine_c = {
          "filename",
        },
        lualine_x = {},
        lualine_y = {
          "encoding",
          "fileformat",
          "filetype",
          { separator = { left = "" } },
        },
        lualine_z = {
          { "location", separator = { right = "" }, left_padding = 2 },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = {
        "nvim-tree",
        "toggleterm",
        "mason",
        "lazy",
        "oil",
        "trouble",
      },
    })
  end,
}
