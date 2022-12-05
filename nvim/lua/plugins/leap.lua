require("leap").add_default_mappings()

vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })

vim.api.nvim_create_autocmd("User", {
  pattern = "LeapLeave",
  callback = function()
    vim.api.nvim_feedkeys("zz", "n", false)
  end,
})
