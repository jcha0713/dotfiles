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
      left_margin = 0.5,
      left_pad = 0.2,
      right_pad = 0.2,
    },
  },
}
