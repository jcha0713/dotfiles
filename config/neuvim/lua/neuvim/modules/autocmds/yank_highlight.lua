local M = {}

function M.init()
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup(
      "neuvim:yank_highlight",
      { clear = true }
    ),
    callback = function()
      vim.hl.on_yank({ on_visual = false })
    end,
  })
end

return M
