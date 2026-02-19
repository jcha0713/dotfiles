-- Wayland clipboard configuration
-- Explicitly use wl-copy/wl-paste for system clipboard integration
vim.g.clipboard = {
  name = "wl-clipboard",
  copy = {
    ["+"] = "wl-copy",
    ["*"] = "wl-copy",
  },
  paste = {
    ["+"] = "wl-paste",
    ["*"] = "wl-paste",
  },
  cache_enabled = 1,
}

local indent = 2 -- num of spaces for indentation

-- vim.opt.guicursor = "n:blinkwait800-blinkon300blinkoff300" -- change cursor shape
vim.opt.winborder = "rounded"
vim.opt.autoindent = true -- auto indent when starting a new line
vim.opt.breakindent = true -- wrapped line is visually indented
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" } -- options for insert mode completion
vim.opt.conceallevel = 0
vim.opt.cursorline = true -- highlight the line of the cursor
vim.opt.dictionary:append({ "/usr/share/dict/words" })
vim.opt.expandtab = true -- use spaces to insert a tab
vim.opt.foldcolumn = "0"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.hlsearch = false -- no highlight for searching
vim.opt.ignorecase = true -- ignore case in search patterns
vim.opt.linebreak = true -- wrap long lines
vim.opt.list = true -- show tabs and trailing spaces
vim.opt.listchars = "tab:» ,trail:·,extends:▸,precedes:◂" -- setting chars for indicating tabs and spaces
vim.opt.mouse = "a" -- enable mouse in all modes
vim.opt.number = true -- show line numbers
vim.opt.pumblend = 3 -- transparency for pmenu
vim.opt.pumheight = 8 -- max number of items to show in the pum
vim.opt.relativenumber = false -- relative line nubers
vim.opt.shiftwidth = indent -- number of spaces to use for indenting
vim.opt.showbreak = "…"
vim.opt.showmatch = true -- jump to the matching bracket when inserted
vim.opt.signcolumn = "auto:2"
vim.opt.smartcase = true -- ignore case if the search pattern contains uppercase letters
vim.opt.smartindent = true -- smart autoindent when starting a new line
vim.opt.smarttab = true -- <BS> deletes a shiftwidth worth of spaces
vim.opt.splitbelow = true -- open new split on bottom
vim.opt.splitright = true -- open new split on bottom
vim.opt.termguicolors = true -- Turn true RGB on
vim.opt.timeoutlen = 200 -- how long to wait for a keymap sequence to complete
vim.opt.updatetime = 250 -- for hover
vim.opt.wildignorecase = true -- ignore case for paths or directories
vim.opt.wildmenu = true -- <Tab> to invoke completion above the command-line
