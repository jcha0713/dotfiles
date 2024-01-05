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

    mason_installer.setup({
      ensure_installed = vim.api.nvim_get_var("lsp_servers"),
    })
  end,
}
