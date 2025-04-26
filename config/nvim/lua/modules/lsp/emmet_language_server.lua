local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
  lspconfig.emmet_language_server.setup({
    on_attach = on_attach,
    capabilities = capabilities or {},
  })
end

return M
