local utils = {}

--- Returns the first argument which is not nil.
---
--- If all arguments are nil, returns nil.
---
--- Examples:
---
--- ```lua
--- local a = nil
--- local b = nil
--- local c = 42
--- local d = true
--- assert(vim.F.if_nil(a, b, c, d) == 42)
--- ```
---
--- Copied from [neovim core](https://github.com/neovim/neovim/blob/master/runtime/lua/vim/F.lua)
--- This will likely be deprecated in the future.
---
---@generic T
---@param ... T
---@return T
function utils.if_nil(...)
  local nargs = select("#", ...)
  for i = 1, nargs do
    local v = select(i, ...)
    if v ~= nil then
      return v
    end
  end
  return nil
end

--- display macOS keys nicely
---@param keymap string
---@return string ...
function utils.to_macos_keys(keymap)
  return keymap
    :gsub("CR", "↩")
    :gsub("<", "")
    :gsub(">", "")
    :gsub("-", " ")
    :gsub("D", "⌘")
    :gsub("A", "⌥")
    :gsub("C", "⌃")
    :gsub("BS", "⌫")
    :gsub("leader", vim.g.mapleader .. " ")
end

function utils.find_root_directory(file_name)
  local file_path = vim.fn.findfile(file_name, ".;")
  if file_path == "" then
    return nil
  end
  return vim.fn.fnamemodify(file_path, ":h")
end

function utils.sort_by_length(ascending)
  if ascending == nil then
    ascending = true
  end

  local selected_lines = vim.api.nvim_buf_get_lines(
    0,
    vim.fn.line("'<") - 1,
    vim.fn.line("'>"),
    false
  )

  table.sort(selected_lines, function(a, b)
    if ascending then
      return #vim.trim(a) < #vim.trim(b)
    end

    return #vim.trim(a) > #vim.trim(b)
  end)

  vim.api.nvim_buf_set_lines(
    0,
    vim.fn.line("'<") - 1,
    vim.fn.line("'>"),
    false,
    selected_lines
  )
end

return utils
