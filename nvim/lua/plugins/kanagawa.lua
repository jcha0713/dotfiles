return {
  "rebelot/kanagawa.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("kanagawa").setup({
      globalStatus = true,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
      overrides = function(colors)
        return {
          Normal = { fg = colors.fujiWhite, bg = "#181820" },
          HopNextKey = { fg = "#ff9900" },
          HopNextKey1 = { fg = "#ff9900" },
          HopNextKey2 = { fg = "#ff9900" },
          TelescopeBorder = { bg = "#181820" },
          WinSeparator = { fg = "#727169" },
          rainbowcol1 = { fg = "#DE6647" },
          rainbowcol2 = { fg = "#FF6185" },
          rainbowcol3 = { fg = "#B594FF" },
          rainbowcol4 = { fg = "#F4A65B" },
          rainbowcol5 = { fg = "#FAE957" },
        }
      end,
    })

    vim.cmd.colorscheme("kanagawa")
  end,
}
