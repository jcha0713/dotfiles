vim.g.mapleader = " "

vim.keymap.set("n", "vv", "<S-v>", { desc = "Select line" })

vim.keymap.set("n", "<leader><leader>q", "<cmd>qa<cr>", { desc = "Quit nvim" })
vim.keymap.set(
  "n",
  "<leader>qo",
  "<cmd>botright cwindow<cr>",
  { desc = "Open quickfix" }
)
vim.keymap.set(
  "n",
  "<leader>qq",
  "<cmd>cclose<cr>",
  { desc = "Close quickfix" }
)
vim.keymap.set("n", "<leader>qd", function()
  vim.diagnostic.setqflist({ title = "Diagnostics" })
end, { desc = "Send diagnostics to quickfix" })

vim.keymap.set("n", "gh", "^", { desc = "Move to first character in line" })
vim.keymap.set("n", "gl", "$", { desc = "Move to last character in line" })
vim.keymap.set("n", "dgh", "d^", { desc = "Delete to first character in line" })
vim.keymap.set("n", "dgl", "d$", { desc = "Delete to last character in line" })
vim.keymap.set("n", "cgh", "c^", { desc = "Change to first character in line" })
vim.keymap.set("n", "cgl", "c$", { desc = "Change to last character in line" })
vim.keymap.set("n", "vgh", "v^", { desc = "Select to first character in line" })
vim.keymap.set("n", "vgl", "v$", { desc = "Select to last character in line" })

vim.keymap.set(
  "n",
  "yc",
  "yygccp",
  { desc = "Comment current line and paste", remap = true }
)

-- set break points for undos
vim.keymap.set("i", ",", ",<C-g>u")
vim.keymap.set("i", ".", ".<C-g>u")
vim.keymap.set("i", "<", "<<C-g>u")
vim.keymap.set("i", ">", "><C-g>u")
vim.keymap.set("i", "(", "(<C-g>u")
vim.keymap.set("i", ")", ")<C-g>u")
vim.keymap.set("i", "[", "[<C-g>u")
vim.keymap.set("i", "]", "]<C-g>u")
