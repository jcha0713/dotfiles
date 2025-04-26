local utils = require("modules.utils")
local map = utils.map

-- vim.g.mapleader = " "

-- easy quit
map("n", "<leader>q", "<cmd>qa<cr>")

-- easy keys for ESC
map("i", "jj", "<C-[>")

-- split windows
map("n", "|", "<cmd>vnew<cr>", { desc = "Split window vertically" })
map("n", "_", "<cmd>new<cr>", { desc = "Split window horizontally" })

-- manage window size
map("n", "<C-w>+", "5<C-w>+")
map("n", "<C-w>-", "5<C-w>-")
map("n", "<C-w><", "5<C-w><")
map("n", "<C-w>>", "5<C-w>>")

-- yank from cursor to the end of the line
map("n", "Y", "y$")

-- source lua file
map("n", "<leader><leader>s", ":luafile %<CR>")

-- move line
map("v", "<C-j>", ":m '>+1<CR>gv=gv")
map("v", "<C-k>", ":m '<-2<CR>gv=gv")

-- vv for select line
map("n", "vv", "<S-v>")

-- Grammar checking in the terminal(using gramma)
map("n", "<leader>cg", ":term gramma check %<cr>", { desc = "Check grammar" })

-- LspRestart
map("n", "<leader>rs", ":LspRestart<CR>:e<CR>", { desc = "Restart LSP" })

-- global yank
map("n", "gy", "ggyG", { desc = "Yank all lines in file" })

-- F and L for first and last character movement
-- and now tesing gh and gl
map("n", "gh", "^", { desc = "Move to first character in line" })
map("n", "gl", "$", { desc = "Move to last character in line" })
map("n", "dgh", "d^", { desc = "Delete to first character in line" })
map("n", "dgl", "d$", { desc = "Delete to last character in line" })
map("n", "cgh", "c^", { desc = "Change to first character in line" })
map("n", "cgl", "c$", { desc = "Change to last character in line" })
map("n", "vgh", "v^", { desc = "Select to first character in line" })
map("n", "vgl", "v$", { desc = "Select to last character in line" })

-- better window movement
-- map("n", "<BS>", "<C-w>h")
-- map("n", "<C-j>", "<C-w>j")
-- map("n", "<C-k>", "<C-w>k")
-- map("n", "<C-l>", "<C-w>l")

-- testing treewalker
map("n", "<C-j>", ":Treewalker Down<CR>zz")
map("n", "<C-k>", ":Treewalker Up<CR>zz")
map("n", "<C-h>", ":Treewalker Left<CR>zz")
map("n", "<C-l>", ":Treewalker Right<CR>zz")

-- Switch buffers
map("n", "]b", ":bnext<CR>", { desc = "Next buffer" })
map("n", "[b", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<Leader>x", ":bd<CR>", { desc = "Close buffer" })

-- Tab navigation
map("n", "<leader>to", ":tabnew<CR>", { desc = "Open new tab" })
map("n", "<leader>ts", ":tab split<CR>", { desc = "Split tab" })
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })

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

map("n", "<C-p>", 'viwp"_dP', { desc = "Paste over selected text" })

vim.keymap.set("i", "<Tab>", function()
  if require("copilot.suggestion").is_visible() then
    require("copilot.suggestion").accept()
  else
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<Tab>", true, false, true),
      "n",
      false
    )
  end
end, { desc = "Super Tab" })

map("n", "<leader><leader>c", function()
  require("modules.custom.auto_commit").generate_commit_message()
end, { desc = "Generate commit messages with AI" })

map("n", "<leader>ge", function()
  require("modules.custom.auto_commit").do_empty_commit()
end, { desc = "Generate empty commit message" })

map(
  "n",
  "yc",
  "yygccp",
  { desc = "Comment current line and paste", remap = true }
)
