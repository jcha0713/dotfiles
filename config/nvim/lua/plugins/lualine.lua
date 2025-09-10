return {
  "nvim-lualine/lualine.nvim",
  enabled = vim.g.nvim_mode ~= "zk",
  event = "VimEnter",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
  },
  config = function()
    local lualine = require("lualine")

    local function get_actions()
      return require("nvim-lightbulb").get_status_text()
    end

    lualine.setup({
      options = {
        icons_enabled = true,
        component_separators = "",
        section_separators = { left = "", right = "" },
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
        lualine_x = { get_actions },
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
