vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("neuvim.lsp", {}),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client == nil then
      return
    end

    -- if client:supports_method("textDocument/completion") then
    --   vim.lsp.completion.enable(true, client.id, event.buf, {
    --     autotrigger = true,
    --   })
    -- end
  end,
})

vim.lsp.enable({
  "cssls",
  "gleam",
  "html",
  "lua_ls",
  "nixd",
  "rust_analyzer",
  "ts_ls",
})
