local cmd = vim.cmd

cmd [[au TextYankPost * lua vim.highlight.on_yank {on_visual = false}]] -- highlint on yank
cmd [[autocmd BufEnter *.txt if &filetype == 'help' | wincmd T | endif]] -- always open help as a new tab
cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]] -- hover
