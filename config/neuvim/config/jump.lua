vim.keymap.set({ "n", "x", "o" }, "s", function()
  require("jump").start()
end, { desc = "Jump to character" })

require("jump").setup({
  label = "Search",
})
