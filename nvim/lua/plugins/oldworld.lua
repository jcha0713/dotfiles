return {
  "dgox16/oldworld.nvim",
  enabled = false,
  lazy = false,
  priority = 1000,
  config = function()
    require("oldworld").setup({
      integrations = {
        indent_blankline = false,
        telescope = false,
      },
    })
  end,
}
