local settings = {
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
      preloadFileSize = 20000,
    },
  },
}

local M = {}

M.setup = function(on_attach, capabilities)
  local opt = {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 150,
    },
    settings = settings,
  }

  local luadev = vim.tbl_deep_extend("force", require("lua-dev").setup(), opt)

  require("lspconfig").sumneko_lua.setup(luadev)
end

return M
