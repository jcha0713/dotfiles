-- vim.g.gruvbox_transparent = true

vim.g.gruvbox_colors = {
  comment = "#888888",
  bg = "#262626",
}

-- override a few theme colors
vim.g.gruvbox_theme = {
  NormalFloat = { bg = "none" },
  -- change highlight colors for hop.nvim
  HopNextKey = { fg = "#ff9900" },
  HopNextKey1 = { fg = "#ff9900" },
  HopNextKey2 = { fg = "#ff9900" },
}

vim.g.gruvbox_flat_style = "dark"
vim.g.gruvbox_hideInactiveStatusline = true

-- set colorscheme to gruvbox-flat
vim.cmd([[colorscheme gruvbox-flat]])

-- highlight for comments
vim.cmd([[highlight Visual guifg=#f7f6f0 guibg=#8a6363]])

-- highlight for cmp: matching characters
vim.cmd([[highlight! CmpItemAbbrMatch guibg=NONE guifg=#d3869b]])
vim.cmd([[highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#d3869b]])

-- highlight for matching parameter in lsp signature popup
vim.cmd([[highlight! LspSignatureActiveParameter guibg=NONE guifg=#4ce0b6]])

-- highlight for winbar
vim.cmd([[highlight! WinBar guifg=#a390a2]])
