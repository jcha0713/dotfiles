return {
  "stevearc/oil.nvim",
  event = "VeryLazy",
  keys = {
    {
      "-",
      "<CMD>Oil<CR>",
      { desc = "Open parent directory" },
    },
  },
  opts = {},
  config = function()
    require("oil").setup({
      delete_to_trash = true,
    })
  end,
}
