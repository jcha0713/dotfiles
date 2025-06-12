return {
  "kylechui/nvim-surround",
  version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      keymaps = {
        visual = "W",
        visual_line = "gW",
        delete = "dp", -- ds is used by flash.nvim
      },
    })
  end,
}
