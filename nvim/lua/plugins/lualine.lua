return {
  "nvim-lualine/lualine.nvim",
  event = "VimEnter",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
  },
  config = function()
    local lualine = require("lualine")

    local function codeium_suggestions()
      local codeium_status =
        vim.trim(vim.api.nvim_call_function("codeium#GetStatusString", {}))
      if codeium_status == "ON" then
        return "󰚩"
      elseif codeium_status == "*" then
        return "󰔟"
      else
        return codeium_status
      end
    end

    lualine.setup({
      options = {
        icons_enabled = true,
        -- theme = "kanagawa",
        -- section_separators = "",
        section_separators = { left = "", right = "" },
        component_separators = "",
        always_divide_middle = true,
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          "diff",
          { "diagnostics", sources = { "nvim_diagnostic" } },
          { codeium_suggestions },
        },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = {},
        lualine_z = { "location" },
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
