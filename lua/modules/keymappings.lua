local utils = require "modules.utils"
local map = utils.map

vim.g.mapleader = " "

-- F and L for first and last character movement
map("n", "F", "^")
map("n", "L", "$")

-- yank from cursor to the end of the line
map("n", "Y", "y$")

-- quickfix
map("n", "Q", ":cw<CR>")
map("n", "]c", ":cn<CR>")
map("n", "[c", ":cp<CR>")

-- map("n", "paw", '"_dawP')
-- map("n", "pi{", '"_di{P')
-- map("n", "pi}", '"_di}P')
-- map("n", "pi(", '"_di(P')
-- map("n", "pi)", '"_di)P')
-- map("n", "pi'", "\"_di'P")
-- map("n", 'pi"', '"_di"P')

-- easy keys for ESC
map("i", "jj", "<C-[>")
map("i", "<C-c>", "")

-- split windows
map("n", "|", "<C-w>v")
map("n", "_", "<C-w>s")

-- MarkdownPreviewToggle
map("n", "<Leader>mp", ":MarkdownPreviewToggle<CR>")

-- paste with Enter key
map("n", "<CR>", "o<ESC>k")

-- leader + esc to exit terminal mode
map("t", "<leader><esc>", "<C-\\><C-n><CR>")

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
map("n", "<Leader>lg", ":Telescope live_grep<CR>")
map("n", "<Leader>bf", ":Telescope buffers<CR>")
map("n", "<Leader>gf", ":Telescope git_files<CR>")
map("n", "<Leader>jp", ":Telescope jumplist<CR>")
map("n", "<Leader>fh", ":Telescope help_tags<CR>")
map("n", "<Leader>fo", ":Telescope oldfiles<CR>")
map("n", "<Leader>fb", ":Telescope file_browser<CR>")
map("n", "<Leader>cm", ":Telescope commands<CR>")
map("n", "<Leader>gs", ":Telescope grep_string<CR>")
map("n", "<Leader>km", ":Telescope keymaps<CR>")
-- utils.map("n", "<C-n>", ":Telescope file_browser<CR>")

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
map("n", "<Leader>k", ":m .-2<CR>==")
map("n", "<Leader>j", ":m .+1<CR>==")

-- vv for select line
map("n", "vv", "<S-v>")

-- Neorg: daily journal
map("n", "<leader>jt", ":Neorg journal today<CR>")

-- Hop.nvim
map("n", "<leader>hl", ":HopLine<CR>")
map("n", "<leader>hw", ":HopWord<CR>")
map("n", "<leader>hc", ":HopChar1<CR>")
map("n", "<leader>hp", ":HopPattern<CR>")

-- diffview.nvim
map("n", "<leader>dv", ":DiffviewOpen<CR>")
map("n", "<leader>dc", ":DiffviewClose<CR>")
map("n", "<leader>dt", ":DiffviewToggleFiles<CR>")

-- neogit
map("n", "<leader>gg", ":Neogit<CR>")

-- Ctrl-p to replace the word under cursor
map("n", "<C-p>", "viwp")

-- Trouble.nvim
map("n", "<leader>tt", ":TroubleToggle<CR>")
map("n", "<leader>twd", ":TroubleToggle workspace_diagnostics<CR>")
map("n", "<leader>tdd", ":TroubleToggle document_diagnostics<CR>")

-- -- Zen-mode
-- map("n", "<leader>zm", ":ZenMode<CR>")

-- Grammar checking in the terminal(using gramma)
map("n", "<leader>gr", ":term gramma check %<cr>")
