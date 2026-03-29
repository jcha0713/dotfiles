local M = {}

function M.init()
  vim.api.nvim_create_autocmd("LspProgress", {
    group = vim.api.nvim_create_augroup(
      "neuvim:lsp_progress",
      { clear = true }
    ),
    callback = function(event)
      local value = event.data.params.value

      vim.api.nvim_echo({ { value.message or "done" } }, false, {
        id = "lsp",
        kind = "progress",
        title = value.title,
        status = value.kind ~= "end" and "running" or "success",
        percent = value.percentage,
      })
    end,
  })
end

return M
