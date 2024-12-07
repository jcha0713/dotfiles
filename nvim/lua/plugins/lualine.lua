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
      violet = "#d183e8",
      grey = "#303030",
    }

    local bubbles_theme = {
      normal = {
        a = { fg = colors.black, bg = colors.violet },
        b = { fg = colors.white, bg = colors.grey },
        c = { fg = colors.white },
      },

      insert = { a = { fg = colors.black, bg = colors.blue } },
      visual = { a = { fg = colors.black, bg = colors.cyan } },
      replace = { a = { fg = colors.black, bg = colors.red } },

      inactive = {
        a = { fg = colors.white, bg = colors.black },
        b = { fg = colors.white, bg = colors.black },
        c = { fg = colors.white },
      },
    }

    local function check_todo()
      local last_todo = require("plugins.custom.idg").get_last_todo()

      if last_todo then
        return last_todo.message
      else
        return "WARNING: NO GOAL HAS BEEN SET!"
      end
    end

    local sections = {
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
      lualine_x = {
        "encoding",
        "fileformat",
        "filetype",
        { separator = { left = "" } },
      },
      lualine_y = {
        check_todo,
      },
      lualine_z = {
        { "location", separator = { right = "" }, left_padding = 2 },
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
      sections = sections,
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
