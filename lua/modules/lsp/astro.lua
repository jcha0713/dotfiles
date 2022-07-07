local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
  lspconfig.astro.setup({
    on_attach = on_attach,
    capabilities = capabilities or {},

    -- this configuration needs to be provided to work with @astrojs/language-server@0.16.1 or greater.
    settings = {
      astro = {
        astro = {
          enabled = true,
          diagnostics = { enabled = true },
          rename = { enabled = true },
          format = { enabled = true },
          completions = { enabled = true },
          hover = { enabled = true },
          codeActions = { enabled = true },
          selectionRange = { enabled = true },
        },

        typescript = {
          enabled = true,
          diagnostics = { enabled = true },
          hover = { enabled = true },
          completions = { enabled = true },
          definitions = { enabled = true },
          findReferences = { enabled = true },
          documentSymbols = { enabled = true },
          codeActions = { enabled = true },
          rename = { enabled = true },
          selectionRange = { enabled = true },
          signatureHelp = { enabled = true },
          semanticTokens = { enabled = true },
          implementation = { enabled = true },
          typeDefinition = { enabled = true },
        },

        css = {
          enabled = true,
          diagnostics = { enabled = true },
          hover = { enabled = true },
          completions = { enabled = true, emmet = true },
          documentColors = { enabled = true },
          colorPresentations = { enabled = true },
          documentSymbols = { enabled = true },
          selectionRange = { enabled = true },
        },

        html = {
          enabled = true,
          hover = { enabled = true },
          completions = { enabled = true, emmet = true },
          tagComplete = { enabled = true },
          documentSymbols = { enabled = true },
          renameTags = { enabled = true },
          linkedEditing = { enabled = true },
        },
      },
    },
  })
end

return M
