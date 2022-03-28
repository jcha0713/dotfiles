require("neorg").setup {
  -- Tell Neorg what modules to load
  load = {
    ["core.defaults"] = {},
    ["core.norg.esupports.metagen"] = {
      config = {
        type = "auto",
        template = {
          {
            "title",
            function()
              return vim.fn.expand "%:p:t:r"
            end,
          },
          { "authors", require("neorg.external.helpers").get_username },
          {
            "created",
            function()
              return os.date "%Y-%m-%d"
            end,
          },
        },
      },
    },
    ["core.norg.concealer"] = {},
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
        engine = "nvim-cmp",
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
