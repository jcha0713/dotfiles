return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local alpha = require("alpha")
    local startify = require("alpha.themes.startify")
    local fortune = require("alpha.fortune")

    startify.section.header.val = {
      [[]],
      [[]],
      [[                                   __                ]],
      [[      ___     ___    ___   __  __ /\_\    ___ ___    ]],
      [[     / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
      [[    /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
      [[    \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
      [[     \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
      [[]],
      [[]],
    }

    startify.section.mru.val = { { type = "padding", val = 0 } }

    local plugins_path = vim.fn.stdpath("config") .. "/lua/plugins/init.lua"

    startify.section.top_buttons.val = {
      startify.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
      startify.button(
        "c",
        "󰸗  Show Calendar",
        ":lua require('telekasten').show_calendar()<CR>"
      ),
      startify.button("l", "󱊒  Open Lazy", ":Lazy<CR>"),
      startify.button(
        "p",
        "󱓓  Edit Plugins",
        ":e " .. plugins_path .. "<CR>"
      ),
      startify.button("f", "󰈞  Find Files", ":Telescope find_files<CR>"),
    }

    startify.section.bottom_buttons.val = {
      startify.button("q", "󰅚  Quit NVIM", ":qa<CR>"),
    }

    -- startify.section.footer.val = {
    --   { type = "text", val = fortune() },
    -- }

    alpha.setup(startify.config)
  end,
}
