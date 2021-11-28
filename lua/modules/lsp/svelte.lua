local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach)
    lspconfig.svelte.setup({
      on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        client.server_capabilities.completionProvider.triggerCharacters = {
          ".", "\"", "'", "`", "/", "@", "*",
          "#", "$", "+", "^", "(", "[", "-", ":",
        }
        on_attach(client, bufnr)
      end,
      filetypes = { "svelte" },
      settings = {
        svelte = {
          plugin = {
            html   = { completions = { enable = true, emmet = false } },
            svelte = { completions = { enable = true, emmet = false } },
            css    = { completions = { enable = true, emmet = true  } },
          },
        },
      },
    })
end

return M


