vim.o.swapfile = false
vim.o.backup = false

vim.o.clipboard = "unnamedplus"

vim.o.keywordprg = "vertical botright help"

-- UI
vim.o.cursorline = true
vim.o.winborder = "rounded"
vim.o.termguicolors = true
vim.o.number = true
vim.o.cursorline = true
vim.o.conceallevel = 0

-- split
vim.o.splitbelow = true
vim.o.splitright = true

-- search
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"

-- indentation
vim.o.smartindent = true
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.tabstop = 2

-- text wrap
vim.o.wrap = false
vim.o.breakindent = true
vim.o.linebreak = true

-- column
vim.o.signcolumn = "yes:1"

-- show tabs and trailing spaces
vim.o.list = true
vim.opt.listchars:append({
  tab = "» ",
  trail = "·",
  extends = "▸",
  precedes = "◂",
})
