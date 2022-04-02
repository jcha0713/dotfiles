require("hop").setup({
  keys = "etovxqpdygfblzhckisuran",
  jump_on_sole_occurrence = true,
})

-- place this in one of your configuration file(s)
vim.api.nvim_set_keymap(
  "n",
  "f",
  "<cmd>lua require'hop'.hint_char1({ direction = nil, current_line_only = true })<cr>",
  {}
)
vim.api.nvim_set_keymap(
  "o",
  "f",
  "<cmd>lua require'hop'.hint_char1({ direction = nil, current_line_only = true, inclusive_jump = true })<cr>",
  {}
)
vim.api.nvim_set_keymap(
  "",
  "t",
  "<cmd>lua require'hop'.hint_char1({ direction = nil, current_line_only = true })<cr>",
  {}
)
vim.api.nvim_set_keymap(
  "",
  "F",
  "<cmd>lua require'hop'.hint_char1({ direction = nil })<cr>",
  {}
)
