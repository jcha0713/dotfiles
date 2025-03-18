local u = require("modules.utils")
local wk = require("which-key")

local M = {}

M.setup = function(on_attach, capabilities)
  require("typescript-tools").setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      -- [typescript-language-server/docs/configuration.md at master · typescript-language-server/typescript-language-server](https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md)
      tsserver_file_preferences = {
        includeInlayParameterNameHints = "all",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
      },
    },
  })

  wk.register({
    name = "TypescriptTools",
    ["<leader>sd"] = {
      "<cmd>TSToolsGoToSourceDefinition<cr>",
      "Go to Source Definition",
    },
  })
  -- require("typescript").setup({
  --   server = {
  --     on_attach = function(client, bufnr)
  --       u.lua_command(
  --         "TSLspOrganize",
  --         "require('typescript').actions.organizeImports()"
  --       )
  --
  --       u.lua_command(
  --         "TSLspImportAll",
  --         "require('typescript').actions.addMissingImports()"
  --       )
  --
  --       u.lua_command(
  --         "TSLspImportAll",
  --         "require('typescript').actions.addMissingImports()"
  --       )
  --
  --       u.lua_command(
  --         "TSLspSourceDef",
  --         "require('typescript').goToSourceDefinition(0, {})"
  --       )
  --
  --       u.buf_map("n", "<leader>oi", ":TSLspOrganize<CR>", nil, bufnr)
  --       u.buf_map("n", "<leader>ia", ":TSLspImportAll<CR>", nil, bufnr)
  --       u.buf_map("n", "<leader>sd", ":TSLspSourceDef<CR>", nil, bufnr)
  --       on_attach(client, bufnr)
  --     end,
  --     capabilities = capabilities,
  --   },
  --   flags = {
  --     -- allow_incremental_sync = true,
  --     debounce_text_changes = 500, -- In ms
  --   },
  -- })
end

return M
