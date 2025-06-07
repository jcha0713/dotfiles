return {
  "j-hui/fidget.nvim",
  enabled = false,
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
        override_vim_notify = true,
        view = {
          stack_upwards = false,
          group_separator = "===",
          group_separator_hl = "String",
        },
        window = {
          winblend = 8,
          border = "rounded",
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
