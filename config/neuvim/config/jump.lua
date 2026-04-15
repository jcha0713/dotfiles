vim.keymap.set({ "n", "x", "o" }, "f", function()
  require("jump").start()
end, { desc = "Jump to character" })

require("jump").setup({
  label = "Search",
})
