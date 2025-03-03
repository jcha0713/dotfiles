local api = vim.api

api.nvim_buf_set_keymap(0, "n", "j", "gj", { noremap = true, silent = true })
api.nvim_buf_set_keymap(0, "n", "k", "gk", { noremap = true, silent = true })

require("luasnip/loaders/from_vscode").lazy_load({
  paths = { "~/.config/nvim/friendly-snippets/" },
})

api.nvim_create_autocmd(
  "FileType",
  { pattern = "markdown", command = "set awa" }
)

-- vim.opt_global.formatoptions = "aw"
