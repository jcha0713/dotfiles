local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
  lspconfig.sourcekit.setup({
    on_attach = function(client)
      on_attach(client)
    end,
    capabilities = capabilities,
    root_dir = lspconfig.util.root_pattern(
      ".xcodeproj",
      "Package.swift",
      ".git"
    ),
  })
end

return M
