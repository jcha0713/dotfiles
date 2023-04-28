return {
  "TimUntersberger/neogit",
  keys = {
    {
      "<leader>gg",
      "<cmd>Neogit<cr>",
      desc = "Open Neogit",
    },
  },
  config = function()
    require("neogit").setup({
      integrations = {
        diffview = true,
      },
    })
  end,
}
