return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    "jose-elias-alvarez/null-ls.nvim",
    "jose-elias-alvarez/typescript.nvim",
    "b0o/schemastore.nvim",
    "ray-x/lsp_signature.nvim",
  },
  config = function()
    require("modules.lsp")
  end,
}
