local api = vim.api
local cmd = vim.cmd

cmd [[au TextYankPost * lua vim.highlight.on_yank {on_visual = false}]] -- highlint on yank
cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {border="rounded", focus=false})]] -- hover

-- cmd [[autocmd BufEnter *.txt if &filetype == 'help' | wincmd T | endif]] -- always open help as a new tab
local help_group = api.nvim_create_augroup("help", { clear = true })
api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if api.nvim_buf_get_option(0, "filetype") == "help" then
      api.nvim_command "wincmd T"
    end
  end,
  group = help_group,
  desc = "Open help as a new tab",
})

-- temporary fix for astro files syntax highlighting
local astro = api.nvim_create_augroup("astro", { clear = true })
api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if api.nvim_buf_get_option(0, "filetype") == "astro" then
      api.nvim_command "edit"
    end
  end,
  group = astro,
  desc = "Fix syntax highlighting for astro files",
})
