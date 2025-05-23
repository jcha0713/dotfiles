return {
  "MeanderingProgrammer/render-markdown.nvim",
  event = "BufEnter",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  }, -- if you prefer nvim-web-devicons
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    code = {
      width = "block",
      left_pad = 2,
      right_pad = 4,
      border = "thin",
    },
  },
}
