require("mfd").setup({
  -- accessibility_contrast = 5,
  -- bright_comments = true,
})

vim.opt.guicursor:append({
  "n:block-CursorNormal",
  "v:block-CursorVisual",
  "i:ver25-CursorInsert",
  "r-cr:block-CursorReplace",
  "c:ver25-CursorCommand",
})

require("mfd").enable_cursor_sync()
