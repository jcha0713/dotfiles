require("neuvim")

vim.pack.add({
  { src = "https://github.com/comfysage/lynn.nvim", name = "lynn" },
})

local pack = require("lynn")
pack.setup("neuvim.plugins")
