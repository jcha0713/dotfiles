local utils = require("modules.utils")
local map = utils.map

vim.g.mapleader = " "

-- PackerSync
map("n", "<leader>ps", ":PackerSync<CR>")

-- easy quit
map("n", "<leader>q", "<cmd>qa<cr>")

-- TSPlaygroundToggle
map("n", "<leader>tsp", ":TSPlaygroundToggle<CR>")

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

-- yank from cursor to the end of the line
map("n", "Y", "y$")

-- quickfix
map("n", "Q", ":cw<CR>")
map("n", "]c", ":cn<CR>")
map("n", "[c", ":cp<CR>")

map("x", "<leader>p", '"_dP')

-- easy keys for ESC
map("i", "jj", "<C-[>")
map("i", "<C-c>", "")

-- split windows
map("n", "|", "<cmd>vnew<cr>")
map("n", "_", "<cmd>new<cr>")

-- manage window size
map("n", "<C-w>+", "5<C-w>+")
map("n", "<C-w>-", "5<C-w>-")
map("n", "<C-w><", "5<C-w><")
map("n", "<C-w>>", "5<C-w>>")

--- Markdown
-- MarkdownPreviewToggle
map("n", "<Leader>mp", ":MarkdownPreviewToggle<CR>")
-- Glow previewer
map("n", "<Leader>gl", ":Glow<CR>")

-- insert a newline
map("n", "<CR>", "o<ESC>k")

-- esc + esc to exit terminal mode
map("t", "<esc>", "<C-\\><C-n>")

-- toggle hl
-- utils.map('n', '<Leader>h', ':set hlsearch!<CR>')

-- explorer
map("n", "<C-n>", ":NvimTreeToggle<CR>")

-- source lua file
map("n", "<Leader>s", ":luafile %<CR>")

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

-- Clear highlight
map("n", "<Leader>nh", "<cmd>noh<CR>")

-- Telescope
map("n", "<M-\\>", ":Telescope<CR>")
map("n", "<Leader>ff", ":Telescope find_files<CR>")
map("n", "<Leader>gr", ":Telescope live_grep<CR>")
map("n", "<Leader>bf", ":Telescope buffers<CR>")
map("n", "<Leader>gf", ":Telescope git_files<CR>")
map("n", "<Leader>jp", ":Telescope jumplist<CR>")
map("n", "<Leader>fh", ":Telescope help_tags<CR>")
map("n", "<Leader>of", ":Telescope oldfiles<CR>")
map("n", "<Leader>fb", ":Telescope file_browser<CR>")
map("n", "<Leader>cm", ":Telescope commands<CR>")
map("n", "<Leader>gs", ":Telescope grep_string<CR>")
map("n", "<Leader>km", ":Telescope keymaps<CR>")
map("n", "<Leader>bm", ":Telescope bookmarks<CR>")
map("n", "<Leader>nosh", ":Telescope neorg search_headings<CR>")
map("n", "<Leader>nop", ":Telescope neorg find_project_tasks<CR>")
map("n", "<Leader>noc", ":Telescope neorg find_context_tasks<CR>")
map("n", "<Leader>noa", ":Telescope neorg find_aof_tasks<CR>")

-- always keep the cursor at center
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "<Leader>j", "mzJ`z")

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

-- vv for select line
map("n", "vv", "<S-v>")

-- Neorg: daily journal
map("n", "<leader>jt", ":Neorg journal today<CR>")
map("n", "<leader>gtdc", ":Neorg gtd capture<CR>")
map("n", "<leader>gtdv", ":Neorg gtd views<CR>")

-- Hop.nvim
map("n", "<leader>hl", ":HopLine<CR>")
map("n", "<leader>hw", ":HopWord<CR>")
map("n", "<leader>hc", ":HopChar1<CR>")
map("n", "<leader>hp", ":HopPattern<CR>")

-- diffview.nvim
map("n", "<leader>dvo", ":DiffviewOpen<CR>")
map("n", "<leader>dvc", ":DiffviewClose<CR>")
map("n", "<leader>dvt", ":DiffviewToggleFiles<CR>")

-- neogit
map("n", "<leader>gg", ":Neogit<CR>")

-- Ctrl-p to replace the word under cursor
map("n", "<C-p>", "viwp")

-- Trouble.nvim
map("n", "<leader>tt", ":TroubleToggle<CR>")
map("n", "<leader>twd", ":TroubleToggle workspace_diagnostics<CR>")
map("n", "<leader>tdd", ":TroubleToggle document_diagnostics<CR>")

-- Grammar checking in the terminal(using gramma)
map("n", "<leader>gc", ":term gramma check %<cr>")

-- add comma and jump
map("i", "<A-,>", "<esc>la,")

-- add colon and jump
map("i", "<A-;>", "<esc>la:")

-- Neogen
map("n", "<leader>ng", ":lua require('neogen').generate()<CR>")

-- LspRestart
map("n", "<leader>rs", ":LspRestart<CR>:e<CR>")

-- SearchBox
map("n", "<M-/>", ":SearchBoxIncSearch<CR>")
map("x", "<M-/>", ":SearchBoxIncSearch visual_mode=true<CR>")
map("x", "<leader>rp", ":SearchBoxReplace<CR>")

-- React extract
map({ "v" }, "<Leader>re", require("react-extract").extract_to_new_file)
map({ "v" }, "<Leader>rc", require("react-extract").extract_to_current_file)
