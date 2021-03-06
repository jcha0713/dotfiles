local o = vim.opt -- vim options
local indent = 2 -- num of spaces for indentation

o.autoindent = true -- auto indent when starting a new line
o.breakindent = true -- wrapped line is visually indented
o.clipboard = "unnamed,unnamedplus"
o.completeopt = { "menu", "menuone", "noinsert", "noselect" } -- options for insert mode completion
o.cursorline = true -- highlight the line of the cursor
o.expandtab = true -- use spaces to insert a tab
o.hlsearch = false -- no highlight for searching
o.ignorecase = true -- ignore case in search patterns
o.linebreak = true -- wrap long lines
o.list = false -- show tabs and trailing spaces
o.listchars = "tab:» ,trail:·" -- setting chars for indicating tabs and spaces
o.mouse = "a" -- enable mouse in all modes
o.number = true -- show line numbers
o.pumblend = 3 -- transparency for pmenu
o.pumheight = 8 -- max number of items to show in the pum
o.relativenumber = true -- relative line nubers
o.shiftwidth = indent -- number of spaces to use for indenting
o.showbreak = "…"
o.showmatch = true -- jump to the matching bracket when inserted
o.smartcase = true -- ignore case if the search pattern contains uppercase letters
o.smartindent = true -- smart autoindent when starting a new line
o.smarttab = true -- <BS> deletes a shiftwidth worth of spaces
o.termguicolors = true -- Turn true RGB on
o.updatetime = 250 -- for hover
o.wildignorecase = true -- ignore case for paths or directories
o.wildmenu = true -- <Tab> to invoke completion above the command-line

vim.opt.dictionary:append({ "/usr/share/dict/words" })
