local THEME_COLOR = "#a390a2"

vim.api.nvim_set_hl(0, "GreetingQuote", { fg = THEME_COLOR, italic = true })

-- use undercurl for errors
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {
  undercurl = true,
})

-- vim.api.nvim_set_hl(0, "Visual", {
--   bg = "#333333",
-- })

vim.api.nvim_set_hl(
  0,
  "CodeiumSuggestion",
  { fg = THEME_COLOR, italic = true, default = true }
)

vim.api.nvim_set_hl(
  0,
  "@markup.strong.markdown_inline",
  { fg = THEME_COLOR, bold = true, default = true }
)

vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", { link = "Visual" })
