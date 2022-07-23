local hop = require("hop")

hop.setup({
  keys = "etovxqpdygfblzhckisuran",
  jump_on_sole_occurrence = true,
})

-- place this in one of your configuration file(s)
vim.keymap.set("", "f", function()
  hop.hint_char1({ direction = nil, current_line_only = true })
end, { remap = true })
vim.keymap.set("", "t", function()
  hop.hint_char1({
    direction = nil,
    current_line_only = true,
    hint_offset = -1,
  })
end, { remap = true })
