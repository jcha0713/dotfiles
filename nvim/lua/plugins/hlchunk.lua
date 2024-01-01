return {
  "shellRaining/hlchunk.nvim",
  event = { "UIEnter" },
  config = function()
    local support_ft = {
      "*.js",
      "*.ts",
      "*.lua",
      "*.rs",
      "*.go",
      "*.json",
    }
    local exclude_ft = {
      startify = true,
    }
    require("hlchunk").setup({
      indent = {
        enable = false,
        support_filetypes = support_ft,
      },
      blank = {
        enable = false,
        support_filetypes = support_ft,
      },
      chunk = {
        chars = {
          horizontal_line = "─",
          vertical_line = "│",
          left_top = "╭",
          left_bottom = "╰",
          right_arrow = ">",
        },
        style = "#806d9c",
        support_filetypes = support_ft,
        exclude_filetypes = exclude_ft,
      },
    })
  end,
}
