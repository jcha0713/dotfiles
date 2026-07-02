require("namu").setup({
  namu_symbols = {
    enable = true,
    options = {
      display = {
        format = "tree_guides",
      },
      row_position = "top10_right",
      preserve_order = true,
    },
  },
})

vim.keymap.set(
  "n",
  "<leader>nc",
  ":Namu call both<cr>",
  { desc = "Namu call both" }
)

vim.keymap.set(
  "n",
  "<leader>nt",
  ":Namu treesitter<cr>",
  { desc = "Namu treesitter" }
)

vim.keymap.set(
  "n",
  "<leader>ns",
  ":Namu symbols<cr>",
  { desc = "Namu symbols" }
)

vim.keymap.set(
  "n",
  "<leader>nd",
  ":Namu diagnostics<cr>",
  { desc = "Namu symbols" }
)
