local api = vim.api

api.nvim_buf_set_keymap(0, "n", "j", "gj", { noremap = true, silent = true })
api.nvim_buf_set_keymap(0, "n", "k", "gk", { noremap = true, silent = true })

-- vim.cmd([[
-- let g:markdown_fenced_languages = ['javascript', 'js=javascript']
-- ]])

-- vim.opt.conceallevel = 2
vim.cmd([[
let g:pencil#wrapModeDefault = 'soft'

augroup pencil
  autocmd!
  autocmd FileType markdown,mkd call pencil#init()
  autocmd FileType text         call pencil#init()
augroup END
]])

local writegood = api.nvim_create_augroup("writegood", { clear = true })
api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    api.nvim_command("WritegoodEnable")
  end,
  group = writegood,
  desc = "Enables writegood plugin for markdown files",
})
