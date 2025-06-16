return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = "Neogit",
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
      graph_style = "kitty",
      integrations = {
        diffview = true,
      },
      sections = {
        recent = {
          folded = false,
        },
      },
    })
  end,
}
