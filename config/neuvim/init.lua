require("neuvim")

vim.pack.add({
  { src = "https://github.com/comfysage/lynn.nvim", name = "lynn" },
})

vim.cmd("packadd nvim.difftool")

local pack = require("lynn")
pack.setup("neuvim.plugins")

vim.cmd.colorscheme("vague")

require("vim._core.ui2").enable({
  enable = true,
  msg = { targets = "cmd" },
})

require("neuvim.lsp")
