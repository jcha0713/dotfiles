return {
  "TimUntersberger/neogit",
  keys = {
    {
      "<leader>gg",
      "<cmd>Neogit<cr>",
      desc = "Open Neogit",
    },
    {
      "<leader>gc",
      "<cmd>Neogit commit<cr>",
      desc = "Neogit commit",
    },
    {
      "<leader>gp",
      "<cmd>Neogit push<cr>",
      desc = "Neogit push",
    },
    {
      "<leader>gl",
      "<cmd>Neogit log<cr>",
      desc = "Neogit log",
    },
  },
  config = function()
    require("neogit").setup({
      disable_commit_confirmation = true,
      integrations = {
        diffview = true,
      },
    })
  end,
}
