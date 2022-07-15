local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
  lspconfig.solang.setup({
    capabilities = capabilities,
    on_attach = function(client)
      on_attach(client)
    end,
    cmd = { "solang", "--language-server", "--target", "ewasm" },
    filetypes = { "solidity" },
  })
end

return M
