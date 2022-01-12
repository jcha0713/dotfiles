require("neorg").setup {
  -- Tell Neorg what modules to load
  load = {
    ["core.defaults"] = {}, -- Load all the default modules
    ["core.norg.concealer"] = {
      config = { -- Note that this table is optional and doesn't need to be provided
        markup = {
          enabled = true,
        },
        markup_preset = "brave",
      },
    },
    ["core.norg.dirman"] = { -- Manage your directories with Neorg
      config = {
        workspaces = {
          organizer = "~/jhcha/note/organizer",
          -- Automatically detect whenever we have entered a subdirectory of a workspace
          autodetect = true,
          -- Automatically change the directory to the root of the workspace every time
          autochdir = true,
        },
      },
    },
    ["core.keybinds"] = { -- Configure core.keybinds
      config = {
        default_keybinds = true, -- Generate the default keybinds
        neorg_leader = "<Leader>o", -- This is the default if unspecified
      },
    },
    ["core.norg.completion"] = {
      config = {
        engine = "nvim-cmp", -- We current support nvim-compe and nvim-cmp only
      },
    },
    ["core.gtd.queries"] = {},
    ["core.gtd.ui"] = {},
    ["core.gtd.base"] = {
      config = {
        workspace = "organizer",
        custom_tag_completion = true,
      },
    },
    ["core.norg.journal"] = {},
  },
}
