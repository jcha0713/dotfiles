require("vim._core.ui2").enable({ enable = true, msg = { target = "msg" } })

vim.ui.select = require("artio").select

vim.keymap.set("n", "<leader>ff", "<Plug>(artio-smart)")
