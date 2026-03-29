vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("neuvim.lsp.ts_ls", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client == nil then
      return
    end

    if client.name == "typescript" then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end

    vim.keymap.set("n", "<leader>oi", function()
      client:exec_cmd({
        title = "Organize Imports",
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(event.buf) }
      })
    end)
  end
})

return {
  cmd = { 'true' },
}
