return {
  "folke/todo-comments.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  config = function()
    require("todo-comments").setup({
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--glob=!hammerspoon",
        },
        pattern = [[\b(KEYWORDS):]],
      },
    })

    vim.keymap.set("n", "<leader>tdt", ":TodoTelescope<CR>")
    vim.keymap.set("n", "<leader>tdq", ":TodoQuickFix<CR>")
  end,
}
