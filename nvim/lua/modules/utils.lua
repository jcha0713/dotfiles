local utils = {}
local api = vim.api

local scopes = { o = vim.o, b = vim.bo, w = vim.wo }

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

local function get_map_options(custom_options)
  local options = { noremap = true, silent = true }
  if custom_options then
    options = vim.tbl_extend("force", options, custom_options)
  end
  return options
end

local function get_map_options_expr(custom_options)
  local options = { expr = true, noremap = true, silent = true }
  if custom_options then
    options = vim.tbl_extend("force", options, custom_options)
  end
  return options
end

function utils.opt(scope, key, value)
  scopes[scope][key] = value
  if scope ~= "o" then
    scopes["o"][key] = value
  end
end

function utils.map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, get_map_options(opts))
end

function utils.map_expr(mode, lhs, rhs, opts)
  api.nvim_set_keymap(mode, lhs, rhs, get_map_options_expr(opts))
end

function utils.buf_map(mode, target, source, opts, bufnr)
  api.nvim_buf_set_keymap(
    bufnr or 0,
    mode,
    target,
    source,
    get_map_options(opts)
  )
end

function utils.lua_command(name, command)
  vim.api.nvim_create_user_command(name, "lua " .. command, {})
end

function utils.some(tbl, cb)
  for key, value in pairs(tbl) do
    if cb(key, value) then
      return true
    end
  end
  return false
end

-- This method returns nil if this buf doesn't have a treesitter parser
-- ref: https://github.com/folke/todo-comments.nvim/blob/ae0a2afb47cf7395dc400e5dc4e05274bf4fb9e0/lua/todo-comments/highlight.lua#L57
--- @return boolean? true or false otherwise
function utils.is_comment(buf, row, col)
  if vim.treesitter.highlighter.active[buf] then
    local captures = vim.treesitter.get_captures_at_pos(buf, row, col)
    for _, c in ipairs(captures) do
      if c.capture == "comment" then
        return true
      end
    end
  else
    local win = vim.fn.bufwinid(buf)
    return win ~= -1
      and vim.api.nvim_win_call(win, function()
        for _, i1 in ipairs(vim.fn.synstack(row + 1, col)) do
          local i2 = vim.fn.synIDtrans(i1)
          local n1 = vim.fn.synIDattr(i1, "name")
          local n2 = vim.fn.synIDattr(i2, "name")
          if n1 == "Comment" or n2 == "Comment" then
            return true
          end
        end
      end)
  end
end

return utils
