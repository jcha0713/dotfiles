local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
  lspconfig.rust_analyzer.setup({
    capabilities = capabilities,
    on_attach = function(client)
      on_attach(client)
    end,
    settings = {
      ["rust_analyzer"] = {
        checkOnSave = {
          allFeatures = true,
          command = "clippy",
        },
      },
    },
  })
end

return M
