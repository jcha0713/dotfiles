local M = {}

function M.init()
  vim.api.nvim_create_autocmd("BufReadPost", {
    desc = "Open file at the last position it was edited earlier",
    group = vim.api.nvim_create_augroup(
      "neuvim.last_position",
      { clear = true }
    ),
    callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(0) then
        vim.api.nvim_win_set_cursor(0, mark)
      end
    end,
  })
end

return M
