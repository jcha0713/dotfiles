local M = {}

M.setup = function(on_attach, capabilities)
  require("lspconfig").prismals.setup({
    on_attach = on_attach,
    capabilities = capabilities or {},
  })
end

return M
