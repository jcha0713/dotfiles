local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach)
    lspconfig.tailwindcss.setup({
      on_attach = function(client)
        on_attach(client)
      end,
      cmd = { 'tailwindcss-language-server', '--stdio' }
    })
end

return M


