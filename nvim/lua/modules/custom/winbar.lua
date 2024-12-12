local M = {}

M.winbar_filetype = {
  "alpha",
  "astro",
  "css",
  "gleam",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "lua",
  "markdown",
  "pug",
  "rust",
  "typescript",
  "typescriptreact",
}

local function check_todo()
  local right_align = "%="
  local last_todo = require("modules.custom.idg").get_last_todo()

  local message = last_todo and last_todo.message or "NO GOAL HAS BEEN SET!"
  return string.format("%s %s ", right_align, message)
end

M.get_winbar = function()
  if not vim.tbl_contains(M.winbar_filetype, vim.bo.filetype) then
    vim.opt_local.winbar = ""
    return
  end

  local winbar = vim.api.nvim_get_option_value("winbar", { scope = "local" })

  if winbar ~= "" then
    return
  end

  local status_ok, _ = pcall(
    vim.api.nvim_set_option_value,
    "winbar",
    check_todo(),
    { scope = "local" }
  )
  if not status_ok then
    return
  end
end

M.update_winbar = function(value)
  value = value or check_todo()

  local status_ok, _ =
    pcall(vim.api.nvim_set_option_value, "winbar", value, { scope = "local" })
  if not status_ok then
    return
  end
end

M.setup = function()
  local group = vim.api.nvim_create_augroup("winbar", { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    group = group,
    callback = function()
      M.get_winbar()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave" }, {
    group = group,
    pattern = { ".git/rebase-merge/git-rebase-todo" },
    callback = function()
      vim.defer_fn(function()
        M.update_winbar()
      end, 300)
    end,
  })
end

return M
