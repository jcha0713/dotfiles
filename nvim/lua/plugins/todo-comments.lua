return {
  "folke/todo-comments.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  event = "BufRead",
  cmd = "TodoTelescope",
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

    vim.keymap.set("n", "]t", function()
      require("todo-comments").jump_next()
    end, { desc = "Next todo comment" })

    vim.keymap.set("n", "[t", function()
      require("todo-comments").jump_prev()
    end, { desc = "Previous todo comment" })
  end,
}
