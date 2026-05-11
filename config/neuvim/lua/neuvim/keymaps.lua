vim.g.mapleader = " "
vim.g.maplocalleader = ";"

vim.keymap.set("n", "vv", "<S-v>", { desc = "Select line" })

vim.keymap.set("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit nvim" })

local function toggle_quickfix()
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      vim.cmd("cclose")
      return
    end
  end

  vim.cmd("botright cwindow")
end

vim.keymap.set("n", "<C-q>", toggle_quickfix, { desc = "Toggle quickfix" })

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
