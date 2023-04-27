local u = require("modules.utils")

local M = {}

M.setup = function(on_attach, capabilities)
  require("typescript").setup({
    server = {
      on_attach = function(client, bufnr)
        u.lua_command(
          "TSLspOrganize",
          "require('typescript').actions.organizeImports()"
        )

        u.lua_command(
          "TSLspImportAll",
          "require('typescript').actions.addMissingImports()"
        )

        u.lua_command(
          "TSLspImportAll",
          "require('typescript').actions.addMissingImports()"
        )

        u.lua_command(
          "TSLspSourceDef",
          "require('typescript').goToSourceDefinition(0, {})"
        )

        u.buf_map("n", "<leader>oi", ":TSLspOrganize<CR>", nil, bufnr)
        u.buf_map("n", "<leader>ia", ":TSLspImportAll<CR>", nil, bufnr)
        u.buf_map("n", "<leader>sd", ":TSLspSourceDef<CR>", nil, bufnr)
        on_attach(client, bufnr)
      end,
      capabilities = capabilities,
    },
    flags = {
      -- allow_incremental_sync = true,
      debounce_text_changes = 500, -- In ms
    },
  })
end

return M
