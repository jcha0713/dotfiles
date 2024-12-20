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

local colors = require("mellifluous.colors").get_colors()
local highlighter = require("mellifluous.utils.highlighter")

local function check_todo()
  local last_todo = require("modules.custom.idg").get_last_todo()

  -- TODO: move this to right place
  if last_todo == "" or last_todo == nil then
    highlighter.set("WinBar", {
      bg = colors.red:darkened(12),
      fg = colors.fg:darkened(100),
    })
  else
    highlighter.set("WinBar", {
      bg = colors.bg:lightened(15),
      fg = colors.purple:lightened(10),
    })
  end

  highlighter.apply_all()

  -- nf-oct
  local message = last_todo and " " .. last_todo.message
    or "('~`;) NO TODO HAS BEEN SET!"
  return string.format("%s ", message)
end

local function get_message(value)
  local content = value or check_todo()

  local right_align = "%="
  local modified = " %-m"
  local file_name = "%f"

  return string.format(
    [[  %s %s%s %s  ]],
    content,
    right_align,
    modified,
    file_name
  )
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

  local message = get_message()

  local status_ok, _ =
    pcall(vim.api.nvim_set_option_value, "winbar", message, { scope = "local" })
  if not status_ok then
    return
  end
end

M.update_winbar = function(value)
  local message = get_message(value)

  local status_ok, _ =
    pcall(vim.api.nvim_set_option_value, "winbar", message, { scope = "local" })
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

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
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
