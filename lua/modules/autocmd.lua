local api = vim.api
local cmd = vim.cmd

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
local qf = api.nvim_create_augroup("qf", { clear = true })
api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "q", "<cmd>ccl<cr>")
  end,
  group = qf,
})
