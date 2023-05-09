return {
  "sindrets/diffview.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  keys = {
    { "<leader>gdo", ":DiffviewOpen<CR>", desc = "Open diffview" },
    {
      "<leader>gD",
      ":DiffviewOpen origin/main<CR>",
      desc = "Diffview -> compare with origin/main",
    },
    { "<leader>gdc", ":DiffviewClose<CR>", desc = "Close diffview" },
  },
  config = function()
    require("diffview").setup({})
  end,
}
