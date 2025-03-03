return {
  "neovim/nvim-lspconfig",
  -- lazy = false,
  event = {
    "BufReadPre",
    "BufNewFile",
  },
  dependencies = {
    "jose-elias-alvarez/null-ls.nvim",
    "jose-elias-alvarez/typescript.nvim",
    "b0o/schemastore.nvim",
    -- hide until https://github.com/ray-x/lsp_signature.nvim/issues/276 is fixed
    -- "ray-x/lsp_signature.nvim",
  },
  config = function()
    require("modules.lsp")
  end,
}
