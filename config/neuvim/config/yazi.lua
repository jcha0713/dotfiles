vim.keymap.set("n", "<C-n>", function()
  require("yazi").yazi()
end, { desc = "Open Yazi" })
