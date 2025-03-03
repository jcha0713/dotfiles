return {
  "williamboman/mason.nvim",
  lazy = false,
  dependencies = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "williamboman/mason-lspconfig.nvim", -- https://arc.net/l/quote/fcpwynoe
  },
  config = function()
    local mason = require("mason")
    local mason_installer = require("mason-tool-installer")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    local tools = {}
    local lsp_servers = vim.api.nvim_get_var("lsp_servers")
    local linters = vim.api.nvim_get_var("lsp_linters")
    local formatters = vim.api.nvim_get_var("lsp_formatters")
    local extras = vim.api.nvim_get_var("extras")

    local function add_values(src_table)
      for _, value in ipairs(src_table) do
        if value ~= "gleam" then
          table.insert(tools, value)
        end
      end
    end

    add_values(lsp_servers)
    add_values(linters)
    add_values(formatters)
    add_values(extras)

    mason_installer.setup({
      ensure_installed = tools,
    })
  end,
}
