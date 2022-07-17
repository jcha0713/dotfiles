local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach)
  lspconfig.cssmodules_ls.setup({
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
    end,
    cmd = { "cssmodules-language-server" },
    filetypes = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
  })
end

return M
