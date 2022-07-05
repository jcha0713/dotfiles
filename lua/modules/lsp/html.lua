local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
  lspconfig.html.setup({
    on_attach = on_attach,
    capabilities = capabilities or {},
    cmd = { "vscode-html-language-server", "--stdio" },
  })
end

return M
