local lspconfig = require("lspconfig")
local u = require("modules.utils")

local ts_utils_settings = {
  -- debug = true,
  enable_import_on_completion = true,
  import_all_scan_buffers = 100,
  update_imports_on_move = true,
  -- filter out dumb module warning
  filter_out_diagnostics_by_code = { 80001 },
}

local M = {}
M.setup = function(on_attach)
  local ts_utils = require("nvim-lsp-ts-utils")

  lspconfig.tsserver.setup({
    init_options = ts_utils.init_options,
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false

      on_attach(client, bufnr)

      ts_utils.setup(ts_utils_settings)
      ts_utils.setup_client(client)

      u.buf_map("n", "gs", ":TSLspOrganize<CR>", nil, bufnr)
      u.buf_map("n", "gI", ":TSLspRenameFile<CR>", nil, bufnr)
      u.buf_map("n", "go", ":TSLspImportAll<CR>", nil, bufnr)

      -- u.buf_map("i", ".", ".<C-x><C-o>", nil, bufnr)
    end,
    flags = {
      debounce_text_changes = 150,
    },
  })
end

return M
