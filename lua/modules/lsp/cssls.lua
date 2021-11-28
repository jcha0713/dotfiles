local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach)
    lspconfig.cssls.setup({
      on_attach = function(client)
        on_attach(client)
      end,
      cmd = { 'vscode-css-language-server', '--stdio' }
    })
end

return M
