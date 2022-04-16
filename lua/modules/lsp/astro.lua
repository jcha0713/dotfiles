local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach)
  lspconfig.astro.setup({
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
    end,
    cmd = { "astro-ls", "--stdio" },
    filetypes = { "astro" },
  })
end

return M
