local cmd = vim.cmd

cmd[[au TextYankPost * lua vim.highlight.on_yank {on_visual = false}]] -- highlint on yank

