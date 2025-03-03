return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      textobjects = {
        select = {
          enable = true,

          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          keymaps = {
            ["af"] = { query = "@function.outer", desc = "select a function" },
            ["if"] = {
              query = "@function.inner",
              desc = "select a function inner",
            },
            ["ab"] = { query = "@block.outer", desc = "select a block" },
            ["ib"] = { query = "@block.inner", desc = "select a block inner" },
            ["ac"] = { query = "@call.outer", desc = "select a call" },
            ["ic"] = { query = "@call.inner", desc = "select a call inner" },
            ["ai"] = {
              query = "@conditional.outer",
              desc = "select a conditional",
            },
            ["ii"] = {
              query = "@conditional.inner",
              desc = "select a conditional inner",
            },
            ["al"] = { query = "@loop.outer", desc = "select a loop" },
            ["il"] = { query = "@loop.inner", desc = "select a loop inner" },
          },
        },
      },
    })
  end,
}
