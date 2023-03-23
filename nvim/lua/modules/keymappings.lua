local utils = require("modules.utils")
local map = utils.map

-- vim.g.mapleader = " "

-- easy quit
map("n", "<leader>q", "<cmd>qa<cr>")

-- easy keys for ESC
map("i", "jj", "<C-[>")

-- split windows
map("n", "|", "<cmd>vnew<cr>")
map("n", "_", "<cmd>new<cr>")

-- manage window size
map("n", "<C-w>+", "5<C-w>+")
map("n", "<C-w>-", "5<C-w>-")
map("n", "<C-w><", "5<C-w><")
map("n", "<C-w>>", "5<C-w>>")

-- yank from cursor to the end of the line
map("n", "Y", "y$")

-- insert a newline
map("n", "<CR>", "o<ESC>k")

-- source lua file
map("n", "<leader>s", ":luafile %<CR>")

-- move line
map("v", "<C-j>", ":m '>+1<CR>gv=gv")
map("v", "<C-k>", ":m '<-2<CR>gv=gv")

-- vv for select line
map("n", "vv", "<S-v>")

-- Grammar checking in the terminal(using gramma)
map("n", "<leader>gc", ":term gramma check %<cr>")

-- LspRestart
map("n", "<leader>rs", ":LspRestart<CR>:e<CR>")

-- global yank
map("n", "gy", "ggyG")

-- quickfix
-- map("n", "Q", ":cw<CR>")
map("n", "]c", ":cn<CR>")
map("n", "[c", ":cp<CR>")

-- F and L for first and last character movement
-- and now tesing gh and gl
map("n", "gh", "^")
map("n", "gl", "$")
map("n", "dgh", "d^")
map("n", "dgl", "d$")
map("n", "cgh", "c^")
map("n", "cgl", "c$")
map("n", "vgh", "v^")
map("n", "vgl", "v$")

-- better window movement
map("n", "<BS>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Switch buffers
map("n", "]b", ":bnext<CR>")
map("n", "[b", ":bprevious<CR>")
map("n", "<Leader>x", ":bd<CR>")

-- Tab navigation
map("n", "<leader>to", ":tabnew<CR>")
map("n", "<leader>ts", ":tab split<CR>")
map("n", "<leader>tc", ":tabclose<CR>")
map("n", "]t", ":tabnext<CR>")
map("n", "[t", ":tabprevious<CR>")

-- set break points for undos
map("i", ",", ",<C-g>u")
map("i", ".", ".<C-g>u")
map("i", "<", "<<C-g>u")
map("i", ">", "><C-g>u")
map("i", "(", "(<C-g>u")
map("i", ")", ")<C-g>u")
map("i", "[", "[<C-g>u")
map("i", "]", "]<C-g>u")

-- move line
map("v", "<C-j>", ":m '>+1<CR>gv=gv")
map("v", "<C-k>", ":m '<-2<CR>gv=gv")

-- add comma and jump
map("i", "<A-,>", "<esc>la,")

-- add colon and jump
map("i", "<A-;>", "<esc>la:")
