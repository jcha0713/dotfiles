local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
  capabilities.workspace = {
    didChangeWatchedFiles = {
      dynamicRegistration = true,
    },
  }

  lspconfig.markdown_oxide.setup({
    on_attach = on_attach,
    capabilities = capabilities or {},
  })
end

return M
