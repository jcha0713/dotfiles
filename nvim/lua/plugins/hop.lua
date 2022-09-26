local hop = require("hop")

hop.setup({
  keys = "etovxqpdygfblzhckisuran",
  jump_on_sole_occurrence = true,
  multi_windows = true,
})

vim.keymap.set("", "f", function()
  hop.hint_char1({
    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
    current_line_only = true,
  })
end, { remap = true })

vim.keymap.set("", "t", function()
  hop.hint_char1({
    direction = require("hop.hint").HintDirection.AFTER_CURSOR,
    current_line_only = true,
    hint_offset = -1,
  })
end, { remap = true })

vim.keymap.set("", "F", function()
  hop.hint_char1({
    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
    current_line_only = true,
  })
end, { remap = true })

vim.keymap.set("", "T", function()
  hop.hint_char1({
    direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
    current_line_only = true,
    hint_offset = -1,
  })
end, { remap = true })
