return {
  "nvim-lualine/lualine.nvim",
  event = "VimEnter",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
  },
  config = function()
    local lualine = require("lualine")

    local function lsp_client()
      local buf_ft = vim.bo.filetype
      local buf_clients = vim.lsp.get_active_clients()
      local buf_client_names = {}

      -- add client
      for _, client in pairs(buf_clients) do
        if client.name == "eslint" then
          table.insert(buf_client_names, client.name)
        end
      end

      -- add linter
      local supported_linters =
        require("modules.lsp.null-ls").list_registered(buf_ft)
      vim.list_extend(buf_client_names, supported_linters)

      return "[" .. table.concat(buf_client_names, ", ") .. "]"
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
          { lsp_client },
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
