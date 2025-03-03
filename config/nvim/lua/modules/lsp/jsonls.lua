local M = {}

M.setup = function(on_attach, capabilities)
  require("lspconfig").jsonls.setup({
    settings = {
      json = {
        schemas = require("schemastore").json.schemas({
          select = {
            "tsconfig.json",
            "package.json",
            "prettierrc.json",
          },
        }),
        validate = { enable = true },
      },
    },
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

return M
