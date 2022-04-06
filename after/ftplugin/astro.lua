vim.cmd("syntax on")
vim.cmd("set syntax=typescriptreact")
local api = vim.api

-- temporary fix for astro files syntax highlighting
local astro = api.nvim_create_augroup("astro", { clear = true })
api.nvim_create_autocmd("FileType", {
  pattern = "astro",
  callback = function()
    api.nvim_command("edit")
  end,
  group = astro,
  desc = "Fix syntax highlighting for astro files",
})
