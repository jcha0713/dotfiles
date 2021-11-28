local utils = {}
local api = vim.api

local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local get_map_options = function(custom_options)
    local options = { noremap = true, silent = true }
    if custom_options then
        options = vim.tbl_extend("force", options, custom_options)
    end
    return options
end

function utils.opt(scope, key, value)
    scopes[scope][key] = value
    if scope ~= 'o' then scopes['o'][key] = value end
end

function utils.map(mode, lhs, rhs, opts)
  api.nvim_set_keymap(mode, lhs, rhs, get_map_options(opts))
end

utils.buf_map = function(mode, target, source, opts, bufnr)
    api.nvim_buf_set_keymap(bufnr or 0, mode, target, source, get_map_options(opts))
end

utils.command = function(name, fn)
    vim.cmd(string.format("command! %s %s", name, fn))
end

utils.lua_command = function(name, fn)
    utils.command(name, "lua " .. fn)
end

return utils

