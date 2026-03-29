local M = {}

function M.init()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup(
      "neuvim.no_auto_comment",
      { clear = true }
    ),
    pattern = "*",
    callback = function()
      vim.opt_local.formatoptions:remove("c")
      vim.opt_local.formatoptions:remove("r")
      vim.opt_local.formatoptions:remove("o")
    end,
  })
end

return M
