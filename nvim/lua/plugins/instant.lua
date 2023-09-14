return {
  "jbyuki/instant.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.instant_username = "jcha0713"
  end,
  keys = {
    {
      "<leader><leader>is",
      "<cmd>InstantStartServer<cr>",
      desc = "Start Instant Server",
    },

    {
      "<leader><leader>is",
      "<cmd>InstantStopServer<cr>",
      desc = "Stop Instant Server",
    },
  },
}
