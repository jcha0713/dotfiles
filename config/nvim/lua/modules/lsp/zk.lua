local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
  lspconfig.zk.setup({
    on_attach = on_attach,
    capabilities = vim.tbl_deep_extend("force", capabilities, {
      workspace = {
        didChangeWatchedFiles = {
          dynamicRegistration = true,
        },
      },
    }),
  })
end

return M
