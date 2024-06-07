return {
  "j-hui/fidget.nvim",
  event = "LspAttach",
  config = function()
    require("fidget").setup({
      progress = {
        display = {
          progress_icon = { "bouncing_ball" },
          done_icon = "😇",
        },
      },
      notification = {
        override_vim_notify = false,
        view = {
          stack_upwards = false,
          group_separator = "===",
          group_separator_hl = "String",
        },
        window = {
          winblend = 8,
          border = "rounded",
          border_hl = "WinBar",
        },
      },
      integration = {
        ["nvim-tree"] = {
          enable = true,
        },
      },
    })
  end,
}
