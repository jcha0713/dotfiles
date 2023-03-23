local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
  lspconfig.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities or {},
    settings = {
      Lua = {
        diagnostics = {
          globals = {
            "vim",
            "use",
            "describe",
            "it",
            "assert",
            "before_each",
            "after_each",
            "hs", -- hammerspoon
          },
        },
        completion = {
          showWord = "Disable",
          callSnippet = "Disable",
          keywordSnippet = "Disable",
        },
        workspace = {
          checkThirdParty = false,
          preloadFileSize = 100000,
          maxPreload = 10000,
        },
      },
    },
  })
end

return M
