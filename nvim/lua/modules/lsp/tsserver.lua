local u = require("modules.utils")

local M = {}

M.setup = function(on_attach, capabilities)
  require("typescript").setup({
    server = {
      on_attach = function(client, bufnr)
        u.buf_map("n", "gs", ":TSLspOrganize<CR>", nil, bufnr)
        u.buf_map("n", "gI", ":TSLspRenameFile<CR>", nil, bufnr)
        u.buf_map("n", "go", ":TSLspImportAll<CR>", nil, bufnr)
        on_attach(client, bufnr)
      end,
    },
    capabilities = capabilities,
    flags = {
      -- allow_incremental_sync = true,
      debounce_text_changes = 500, -- In ms
    },
  })
end

return M
