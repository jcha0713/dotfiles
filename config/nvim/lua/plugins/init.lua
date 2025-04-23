return {
  -- lua utils for neovim
  { "nvim-lua/plenary.nvim", branch = "master" },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,

    config = function()
      vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>")
    end,
  },

  {
    "wallpants/github-preview.nvim",
    enabled = false,
    cmd = { "GithubPreviewToggle" },
    ft = { "markdown" },
    event = "VeryLazy",
    config = function(_, opts)
      local gpreview = require("github-preview")
      gpreview.setup(opts)

      local fns = gpreview.fns
      vim.keymap.set("n", "<leader>mp", fns.toggle)
    end,
  },

  -- cmp-fuzzy-buffer: buffer source using fuzzy
  {
    "tzachar/cmp-fuzzy-buffer",
    dependencies = { "hrsh7th/nvim-cmp", "tzachar/fuzzy.nvim" },
  },

  -- nvim-surround: nvim version of vim-surround
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          visual = "W",
          visual_line = "gW",
          delete = "dp", -- ds is used by flash.nvim
        },
      })
    end,
  },

  {
    "tzachar/fuzzy.nvim",
    dependencies = { "hrsh7th/nvim-cmp", "tzachar/fuzzy.nvim" },
  },

  -- neogen: docstring generator
  {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    keys = {
      {
        "<leader>ng",
        ":lua require('neogen').generate()<CR>",
        "generate doc",
      },
    },
    config = function()
      require("neogen").setup({
        enabled = true,
        input_after_comment = true,
        snippet_engine = "luasnip",
      })
    end,
    -- Uncomment next line if you want to follow only stable versions
    version = "*",
  },

  {
    "brenoprata10/nvim-highlight-colors",
    event = "VeryLazy",
    config = function()
      require("nvim-highlight-colors").setup({
        render = "virtual",
        virtual_symbol = "█",
        enable_tailwind = true,
      })
    end,
  },

  -- emmet-vim: support for emmet
  {
    "mattn/emmet-vim",
    event = "BufEnter",
    ft = { "html", "javascriptreact", "typescriptreact" },
    init = function()
      vim.g["user_emmet_leader_key"] = "<C-,>"
      vim.g["user_emmet_settings"] = [[{'astro': {'extends' : 'html',}}]]
    end,
  },

  -- trouble.nvim: error fix using quickfix list
  {
    "folke/trouble.nvim",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      vim.keymap.set("n", "<leader>tt", ":TroubleToggle<CR>")
      vim.keymap.set(
        "n",
        "<leader>wd",
        ":TroubleToggle workspace_diagnostics<CR>"
      )
      vim.keymap.set(
        "n",
        "<leader>dd",
        ":TroubleToggle document_diagnostics<CR>"
      )
      vim.keymap.set("n", "Q", ":TroubleToggle quickfix<CR>")
    end,
  },

  {
    "notjedi/nvim-rooter.lua",
    event = "BufEnter",
    config = function()
      require("nvim-rooter").setup()
    end,
  },

  -- Latex in markdown
  {
    "jbyuki/nabla.nvim",
    ft = { "markdown" },
    keys = {
      {
        "<leader>ma",
        function()
          require("nabla").enable_virt()
        end,
      },
    },
  },

  -- Rust
  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- Recommended
    ft = { "rust" },
  },

  -- Profiling
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    init = function()
      vim.g.startuptime_tries = 10
    end,
  },

  -- crates.io
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    version = "v0.3.0",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup()
    end,
  },

  -- cosmic-ui
  {
    "CosmicNvim/cosmic-ui",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      require("cosmic-ui").setup({
        border_style = "rounded",
      })
    end,
  },

  -- -- extracting react components
  -- {
  --   "jcha0713/react-extract.nvim",
  --   branch = "fix",
  --   config = function()
  --     require("plugins.react-extract")
  --   end,
  -- },

  -- mdx
  { "jxnblk/vim-mdx-js", ft = "markdown" },

  -- nim
  { "alaviss/nim.nvim", ft = "nim" },

  -- just for fun
  {
    "tamton-aquib/duck.nvim",
    keys = {
      {
        -- for the talk
        -- "<leader><leader>h",
        "<Home>",
        function()
          require("duck").hatch("❄️", 5)
          require("duck").hatch("❄️", 5)
          require("duck").hatch("❄️", 5)
          require("duck").hatch("❄️", 3)
          require("duck").hatch("❄️", 3)
        end,
        desc = "Make it cuter",
      },
    },
    config = function()
      vim.keymap.set("n", "<leader><leader>r", function()
        require("duck").cook()
      end)
    end,
  },

  -- TODO: fork and customize
  -- {
  --   "phaazon/mind.nvim",
  --   branch = "v2.2",
  --   keys = {
  --     {
  --       "<leader>mdm",
  --       ":MindOpenMain<CR>",
  --     },
  --     {
  --       "<leader>mdp",
  --       function()
  --         require("nvim-rooter").rooter()
  --         require("mind").open_project(true)
  --       end,
  --     },
  --     {
  --       "<leader>mdc",
  --       ":MindClose<CR>",
  --     },
  --   },
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   config = function()
  --     require("mind").setup()
  --   end,
  -- },

  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
  },

  -- {
  --   "zbirenbaum/copilot.lua",
  --   event = "InsertEnter",
  --   build = ":Copilot auth",
  --   opts = {
  --     suggestion = {
  --       auto_trigger = true,
  --       keymap = {
  --         accept = false,
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     require("copilot").setup(opts)
  --   end,
  -- },

  -- {
  --   dir = "~/jhcha/dev/2023/project/copilot.lua",
  --   event = "InsertEnter",
  --   build = ":Copilot auth",
  --   opts = {
  --     suggestion = {
  --       auto_trigger = true,
  --       keymap = {
  --         accept = false,
  --       },
  --     },
  --     filetypes = {
  --       go = false,
  --     },
  --   },
  --   config = function(_, opts)
  --     require("copilot").setup(opts)
  --   end,
  -- },
  --

  {
    "gleam-lang/gleam.vim",
    ft = "gleam",
  },

  -- {
  --   "zbirenbaum/neodim",
  --   event = "LspAttach",
  --   config = function()
  --     require("neodim").setup({
  --       refresh_delay = 75,
  --       alpha = 0.5,
  --       blend_color = "#000000",
  --       hide = {
  --         underline = true,
  --         virtual_text = true,
  --         signs = true,
  --       },
  --       regex = {
  --         "[uU]nused",
  --         "[nN]ever [rR]ead",
  --         "[nN]ot [rR]ead",
  --       },
  --       priority = 128,
  --       disable = {},
  --     })
  --   end,
  -- },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    event = "BufEnter",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

  -- {
  --   "lukas-reineke/headlines.nvim",
  --   event = "VeryLazy",
  --   dependencies = "nvim-treesitter/nvim-treesitter",
  --   config = function()
  --     require("headlines").setup({
  --       markdown = {
  --         fat_headline_lower_string = "▀",
  --         bullets = { "󰎤", "󰎧", "󰎪", "󰎭", "󰎱" },
  --         headline_highlights = {
  --           "Headline1",
  --           "Headline2",
  --           "Headline3",
  --           "Headline4",
  --           "Headline5",
  --         },
  --       },
  --     })
  --   end,
  -- },

  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>ol", ":Outline<CR>", desc = "Toggle outline" },
    },
    config = function()
      require("outline").setup({
        outline_window = {
          focus_on_open = false,
        },
        outline_items = {
          show_symbol_details = false,
          show_symbol_lineno = true,
          hide_cursor = true,
        },
        symbols = {
          icons = {
            File = { icon = "", hl = "@text.uri" },
            Module = { icon = "", hl = "@namespace" },
            Namespace = { icon = "", hl = "@namespace" },
            Package = { icon = "", hl = "@namespace" },
            Class = { icon = "", hl = "@type" },
            Method = { icon = "ƒ", hl = "@method" },
            Property = { icon = "", hl = "@method" },
            Field = { icon = "", hl = "@field" },
            Constructor = { icon = "", hl = "@constructor" },
            Enum = { icon = "", hl = "@type" },
            Interface = { icon = "", hl = "@type" },
            Function = { icon = "", hl = "@function" },
            Variable = { icon = "", hl = "@constant" },
            Constant = { icon = "", hl = "@constant" },
            String = { icon = "", hl = "@string" },
            Number = { icon = "#", hl = "@number" },
            Boolean = { icon = "", hl = "@boolean" },
            Array = { icon = "", hl = "@constant" },
            Object = { icon = "", hl = "@type" },
            Key = { icon = "", hl = "@type" },
            Null = { icon = "", hl = "@type" },
            EnumMember = { icon = "", hl = "@field" },
            Struct = { icon = "", hl = "@type" },
            Event = { icon = "", hl = "@type" },
            Operator = { icon = "", hl = "@operator" },
            TypeParameter = { icon = "", hl = "@parameter" },
            Component = { icon = "", hl = "@function" },
            Fragment = { icon = "", hl = "@constant" },
          },
        },
      })
    end,
  },
  {
    "pwntester/octo.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("octo").setup({
        suppress_missing_scope = {
          projects_v2 = true,
        },
      })
    end,
  },
  -- {
  --   "sidebar-nvim/sidebar.nvim",
  --   event = { "BufReadPre", "BufNewFile" },
  --   keys = {
  --     {
  --       "<leader><leader>s",
  --       ":SidebarNvimToggle<CR>",
  --       desc = "Toggle Sidebar",
  --     },
  --   },
  --   config = function()
  --     require("sidebar-nvim").setup({
  --       bindings = {
  --         ["q"] = function()
  --           require("sidebar-nvim").close()
  --         end,
  --         -- ["t"] = function()
  --         --   require("sidebar-nvim.builtin.todos").toggle_all()
  --         -- end,
  --       },
  --       sections = { "todos", "diagnostics" },
  --       todos = {
  --         icon = "",
  --         ignored_paths = { "~" },
  --       },
  --     })
  --   end,
  -- },

  {
    "supermaven-inc/supermaven-nvim",
    event = "BufEnter",
    config = function()
      local api = require("supermaven-nvim.api")

      require("supermaven-nvim").setup({
        ignore_filetypes = { markdown = true, gleam = true },
      })

      api.stop()
    end,
  },
  {
    "otavioschwanck/telescope-cmdline-word.nvim",
    event = "BufEnter",
    opts = {
      add_mappings = true, -- add <tab> mapping automatically
    },
  },
  {
    "jcha0713/backseat.nvim",
    enabled = false,
    event = "VeryLazy",
    dir = "~/jhcha/dev/2024/project/backseat.nvim",
    keys = {
      {
        mode = "v",
        "<leader><leader>p",
        ":Backseat<CR>",
        desc = "Send Backseat request",
      },
    },
    config = function()
      require("backseat").setup({
        openai_model_id = "gpt-3.5-turbo", --gpt-4 (If you do not have access to a model, it says "The model does not exist")
      })
    end,
  },
  {
    "David-Kunz/gen.nvim",
    event = "VeryLazy",
    opts = {
      display_mode = "split",
      show_prompt = true,
    },
  },

  -- {
  --   "napisani/nvim-github-codesearch",
  --   event = "VeryLazy",
  --   build = "make",
  --   config = function()
  --     local gh_search = require("nvim-github-codesearch")
  --
  --     gh_search.setup({
  --       use_telescope = true,
  --     })
  --
  --     vim.keymap.set("n", "<leader>ghs", function()
  --       gh_search.prompt()
  --     end)
  --   end,
  -- },

  {
    "danielfalk/smart-open.nvim",
    branch = "0.2.x",
    keys = {
      {
        "gs",
        function()
          require("telescope").extensions.smart_open.smart_open()
        end,
        desc = "Smart Open",
      },
    },
    dependencies = {
      "kkharji/sqlite.lua",
      -- Only required if using match_algorithm fzf
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
      { "nvim-telescope/telescope-fzy-native.nvim" },
    },
  },

  {
    "vuki656/package-info.nvim",
    ft = "json",
    event = "VeryLazy",
    requires = "MunifTanjim/nui.nvim",
    config = true,
  },

  {
    "luckasRanarison/clear-action.nvim",
    event = "VeryLazy",
    config = true,
  },

  {
    "aznhe21/actions-preview.nvim",
    event = "VeryLazy",
    config = true,
  },

  {
    "grapp-dev/nui-components.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },

  {
    "aaronik/treewalker.nvim",
    event = "VeryLazy",
    opts = {
      highlight = true,
    },
  },

  -- {
  --   "vim-fall/fall.vim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     "vim-denops/denops.vim",
  --   },
  --   config = function()
  --     local opts = { noremap = true, silent = true }
  --     vim.keymap.set("c", "<C-n>", "<Plug>(fall-list-next)", opts)
  --     vim.keymap.set("c", "<C-p>", "<Plug>(fall-list-prev)", opts)
  --     vim.keymap.set("c", "<Tab>", "<Plug>(fall-action-select)", opts)
  --   end,
  -- },

  {
    "moyiz/git-dev.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },
}
