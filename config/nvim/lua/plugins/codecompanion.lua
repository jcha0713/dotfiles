return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "deepseek",
        },
      },
      adapters = {
        deepseek = function()
          return require("codecompanion.adapters").extend("deepseek", {
            env = {
              api_key = "cmd:op read op://private/DEEPSEEK-API-KEY/credential --no-newline",
            },
            schema = {
              model = {
                default = "deepseek-reasoner",
              },
            },
          })
        end,
      },
    })
  end,
}
