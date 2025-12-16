return {
  "webhooked/kanso.nvim",
  lazy = false,
  enabled = true,
  priority = 1000,

  config = function()
    require("kanso").setup({
      overrides = function(colors)
        return {
          FloatBorder = {
            fg = colors.palette.zenBlue1,
          },
          WinSeparator = {
            fg = colors.palette.zenBg3,
          },
        }
      end,
    })

    vim.cmd.colorscheme("kanso")
  end,
}
