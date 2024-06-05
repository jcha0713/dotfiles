local api = vim.api
local cmd = vim.cmd
local augroup = api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd

cmd([[au TextYankPost * lua vim.highlight.on_yank {on_visual = false}]]) -- highlint on yank
-- cmd(
--   [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {border="rounded", focus=false})]]
-- ) -- hover

-- -- cmd [[autocmd BufEnter *.txt if &filetype == 'help' | wincmd T | endif]] -- always open help as a new tab
-- local help_group = api.nvim_create_augroup("help", { clear = true })
-- api.nvim_create_autocmd("FileType", {
--   pattern = "help",
--   callback = function()
--     api.nvim_command "wincmd T"
--   end,
--   group = help_group,
--   desc = "Open help as a new tab",
-- })

-- q to quit quickfix list
local qf = augroup("qf", { clear = true })
autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "q", "<cmd>ccl<cr>")
  end,
  group = qf,
})

-- attach winbar
local winbar = augroup("winbar", { clear = true })
autocmd({
  "CursorMoved",
  "BufWinEnter",
  "BufFilePost",
  "InsertEnter",
  "BufWritePost",
}, {
  callback = function()
    require("plugins.custom.winbar").get_winbar()
  end,
  group = winbar,
})

-- don't auto insert comments when starting a newline
local no_comments = augroup("no_comments", { clear = true })
autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove("c")
    vim.opt_local.formatoptions:remove("r")
    vim.opt_local.formatoptions:remove("o")
  end,
  group = no_comments,
})

-- TODO: temporary solution to run nph command
-- delete later when it's not needed
vim.api.nvim_create_augroup("AutoFormatting", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.nim",
  group = "AutoFormatting",
  callback = function()
    local filename = vim.fn.expand("%:p")
    vim.cmd("silent ! nph " .. filename)
  end,
})

local disable_supermaven =
  vim.api.nvim_create_augroup("DisableSupermaven", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = disable_supermaven,
  callback = function()
    local filepath = vim.fn.expand("%:h")

    if type(filepath) ~= "string" then
      filepath = filepath[0]
    end

    local splitted = vim.split(filepath, "/")

    if splitted[#splitted] == "leetcode" then
      vim.cmd("SupermavenStop")
    end
  end,
})

local last_position = augroup("misc", { clear = true })

vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Open file at the last position it was edited earlier",
  group = last_position,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})
