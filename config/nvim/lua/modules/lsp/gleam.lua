local M = {}

M.setup = function(on_attach, capabilities)
  require("lspconfig").gleam.setup({
    on_attach = on_attach,
    capabilities = capabilities or {},
  })
end

return M
