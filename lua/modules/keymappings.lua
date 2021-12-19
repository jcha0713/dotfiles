local utils = require "modules.utils"

vim.g.mapleader = " "

-- full help page
utils.map("c", ":help", ":tab help<CR>")

-- easy keys for ESC
utils.map("i", "jj", "<ESC>")

-- change colorscheme to gruvbox
utils.map("n", "<Leader>cc", ":colorscheme gruvbox<CR>")

-- split windows
utils.map("n", "<Leader>|", "<C-W>v")
utils.map("n", "<Leader>_", "<C-W>s")

-- fzf-dictionary
vim.cmd [[  imap <C-l> <Plug>(fzf-dictionary-open) ]]

-- paste with Enter key
utils.map("n", "<CR>", "o<ESC>k")

-- toggle hl
-- utils.map('n', '<Leader>h', ':set hlsearch!<CR>')

-- explorer
utils.map("n", "<C-n>", ":NvimTreeToggle<CR>")

-- source lua file
utils.map("n", "<Leader>s", ":luafile %<CR>")

-- better window movement
utils.map("n", "<C-h>", "<C-w>h")
utils.map("n", "<C-j>", "<C-w>j")
utils.map("n", "<C-k>", "<C-w>k")
utils.map("n", "<C-l>", "<C-w>l")

-- Switch buffers
utils.map("n", "<S-k>", ":BufferLineCycleNext<CR>")
utils.map("n", "<S-j>", ":BufferLineCyclePrev<CR>")
utils.map("n", "<Leader>x", ":bdelete<CR>")

-- Rainbow Parentheses
utils.map("n", "<Leader>p", ":RainbowParentheses!!<CR>")

-- Clear highlight
utils.map("n", "<Leader>n", "<cmd>noh<CR>")

-- Telescope
utils.map("n", "<Leader>ff", ":Telescope find_files<CR>")
utils.map("n", "<Leader>fg", ":Telescope live_grep<CR>")
utils.map("n", "<Leader>fb", ":Telescope buffers<CR>")
utils.map("n", "<Leader>fr", ":Telescope projects<CR>")
utils.map("n", "<Leader>fh", ":Telescope help_tags<CR>")
utils.map("n", "<Leader>fo", ":Telescope oldfiles<CR>")

-- always keep the cursor at center
utils.map("n", "n", "nzzzv")
utils.map("n", "N", "Nzzzv")
utils.map("n", "<Leader>j", "mzJ`z")

-- set break points for undos
utils.map("i", ",", ",<C-g>u")
utils.map("i", ".", ".<C-g>u")
utils.map("i", "<", "<<C-g>u")
utils.map("i", ">", "><C-g>u")
utils.map("i", "(", "(<C-g>u")
utils.map("i", ")", ")<C-g>u")
utils.map("i", "[", "[<C-g>u")
utils.map("i", "]", "]<C-g>u")

-- move line
utils.map("v", "<C-j>", ":m '>+1<CR>gv=gv")
utils.map("v", "<C-k>", ":m '<-2<CR>gv=gv")
utils.map("n", "<Leader>k", ":m .-2<CR>==")
utils.map("n", "<Leader>j", ":m .+1<CR>==")

-- vv for select line
utils.map("n", "vv", "<S-v>")
