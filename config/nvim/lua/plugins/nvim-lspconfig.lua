return {
  "neovim/nvim-lspconfig",
  -- lazy = false,
  event = {
    "BufReadPre",
    "BufNewFile",
  },
  dependencies = {
    "b0o/schemastore.nvim",
  },
  config = function()
    require("modules.lsp")
  end,
}
