-- code reference: https://github.com/geodimm/dotfiles/blob/main/nvim/after/plugin/alpha-nvim.lua

return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local alpha = require("alpha")
    local lazy = require("lazy")
    local devicons = require("nvim-web-devicons")
    local startify = require("alpha.themes.startify")
    local fortune = require("alpha.fortune")

    local function surround(v)
      return " " .. v .. " "
    end

    local info_text = function()
      local total_plugins = lazy.stats().count
      local datetime = os.date(surround("󰸗") .. "%Y-%m-%d")
      local version = vim.version()
      local nvim_version_info = surround(
        devicons.get_icon_by_filetype("vim", {})
      ) .. "v" .. version.major .. "." .. version.minor .. "." .. version.patch

      return "        "
        .. datetime
        .. surround("󰐱")
        .. total_plugins
        .. " plugins"
        .. nvim_version_info
    end

    local info = {
      type = "text",
      val = info_text(),
      opts = {
        hl = "Comment",
        position = "left",
      },
    }

    local neovim_logo = {
      type = "text",
      val = {
        -- [[╭───────────────────────────────────────────────────────╮]],
        -- [[│                                                       │]],
        -- [[│     ___     ___    ___   __  __ /\_\    ___ ___       │]],
        -- [[│    / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\     │]],
        -- [[│   /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \    │]],
        -- [[│   \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\   │]],
        -- [[│    \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/   │]],
        -- [[│                                                       │]],
        -- [[│                                                       │]],
        -- [[╰───────────────────────────────────────────────────────╯]],
        [[]],
        [[]],
        [[        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢎⠱⠊⡱⠀⠀⠀⠀⠀⠀    ]],
        [[         ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠤⠒⠒⠒⠒⠤⢄⣑⠁⠀⠀⠀⠀⠀⠀⠀    ]],
        [[        ⠀⠀⠀⠀⠀⠀⠀⢀⡤⠒⠝⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠲⢄⡀⠀⠀⠀⠀⠀    ]],
        [[        ⠀⠀⠀⠀⠀⢀⡴⠋⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⢰⣢⠐⡄⠀⠉⠑⠒⠒⠒⣄    ]],
        [[        ⠀⠀⠀⣀⠴⠋⠀⠀⠀⡎⠀⠘⠿⠀⠀⢠⣀⢄⡢⠉⣔⣲⢸⠀⠀⠀⠀⠀⠀⢘    ]],
        [[        ⡠⠒⠉⠀⠀⠀⠀⠀⡰⢅⠫⠭⠝⠀⠀⠀⠀⠀⠀⢀⣀⣤⡋⠙⠢⢄⣀⣀⡠⠊    ]],
        [[        ⢇⠀⠀⠀⠀⠀⢀⠜⠁⠀⠉⡕⠒⠒⠒⠒⠒⠛⠉⠹⡄⣀⠘⡄⠀⠀⠀⠀⠀⠀    ]],
        [[        ⠀⠑⠂⠤⠔⠒⠁⠀⠀⡎⠱⡃⠀⠀⡄⠀⠄⠀⠀⠠⠟⠉⡷⠁⠀⠀⠀⠀⠀⠀    ]],
        [[        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⠤⠤⠴⣄⡸⠤⣄⠴⠤⠴⠄⠼⠀⠀⠀⠀⠀⠀⠀⠀    ]],
        [[]],
        [[]],
      },
      opts = {
        hl = "String",
      },
    }

    local message = {
      type = "text",
      val = fortune({ max_width = 60 }),
      opts = {
        position = "left",
        hl = "GreetingQuote",
      },
    }

    local header = {
      type = "group",
      val = {
        neovim_logo,
        info,
        { type = "padding", val = 1 },
        message,
      },
    }
    startify.section.mru.val = { { type = "padding", val = 0 } }
    startify.section.mru_cwd.val = { { type = "padding", val = 0 } }

    local plugins_path = vim.fn.stdpath("config") .. "/lua/plugins/init.lua"

    local basic = {
      type = "group",
      val = {
        {
          type = "text",
          val = "Basic Actions",
          opts = {
            hl = "String",
            shrink_margin = false,
            position = "left",
          },
        },
        { type = "padding", val = 1 },
        startify.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
        startify.button(
          "p",
          "󱓓  Edit Plugins",
          ":e " .. plugins_path .. "<CR>"
        ),
        startify.button("g", "󰊢  Git Status", ":Neogit<CR>"),
        startify.button("q", "󰅚  Quit NVIM", ":qa<CR>"),
      },
    }

    local search = {
      type = "group",
      val = {
        {
          type = "text",
          val = "Search",
          opts = {
            hl = "String",
            shrink_margin = false,
            position = "left",
          },
        },
        { type = "padding", val = 1 },

        startify.button("f", "󰈞  Find Files", ":Telescope find_files<CR>"),
        startify.button("s", "󱇻  Smart Open", ":Telescope smart_open<CR>"),
        startify.button("o", "󱇻  Recent Files", ":Telescope oldfiles<CR>"),
        startify.button("t", "  Todos", ":TodoTelescope<CR>"),
      },
    }

    startify.config.layout = {
      header,
      { type = "padding", val = 2 },
      search,
      { type = "padding", val = 1 },
      basic,
    }

    alpha.setup(startify.config)
  end,
}
