local lspconfig = require("lspconfig")
local util = require 'lspconfig.util'

local M = {}

M.setup = function(on_attach, capabilities)
    lspconfig.emmet_language_server.setup({
      on_attach = function(client)
        on_attach(client)
      end,
      capabilities = capabilities,
      root_dir = function(fname)
        return util.root_pattern('package.json', 'tsconfig.json', 'jsconfig.json', '.git')(fname)
      end,
    })
end

return M
