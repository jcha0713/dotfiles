vim.o.swapfile = false
vim.o.backup = false

vim.o.clipboard = "unnamedplus"

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
vim.opt.switchbuf:append("vsplit")

-- search
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"

-- use rg for grepping
vim.o.grepprg = vim.fn.executable("rg") == 1
    and "rg --vimgrep --smart-case --hidden --glob '!.git' --"
  or "grep -rni --"
vim.o.grepformat = "%f:%l:%c:%m"

-- indentation
vim.o.smartindent = true
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.tabstop = 2

-- text wrap
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
