return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    input = {},
    notifier = {
      style = "compact",
      top_down = false,
      margin = { bottom = 1 },
    },
    styles = {
      input = {
        relative = "cursor",
        row = -3,
        col = -2,
      },
    },
  },
}
