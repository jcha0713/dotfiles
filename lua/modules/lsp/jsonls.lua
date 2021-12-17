local M = {}

M.setup = function(on_attach)
  require("lspconfig").jsonls.setup {
    filetypes = { "json", "jsonc" },
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
      },
    },
    on_attach = function(client)
      client.resolved_capabilities.document_formatting = false

      on_attach(client)
    end,
  }
end

return M
