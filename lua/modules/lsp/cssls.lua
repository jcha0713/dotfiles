local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
  lspconfig.cssls.setup({
    on_attach = function(client)
      on_attach(client)
    end,
    capabilities = capabilities or {},
    cmd = { "vscode-css-language-server", "--stdio" },
    settings = {
      css = {
        lint = {
          unknownAtRules = "ignore",
        },
      },
    },
    filetypes = {
      "css",
      "scss",
    },
  })
end

return M
