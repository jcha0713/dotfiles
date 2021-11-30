local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
    lspconfig.html.setup({
      on_attach = function(client)
        on_attach(client)
      end,
      capabilities = capabilities,
      cmd = { 'vscode-html-language-server', '--stdio' }
    })
end

return M
