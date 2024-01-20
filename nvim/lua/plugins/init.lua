return {
  -- neodev: For better lua lsp configuration
  { "folke/neodev.nvim", ft = "lua" },

  -- lua utils for neovim
  "nvim-lua/plenary.nvim",

  -- markdown-preview: preview for *.md
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
    keys = {
      { "<leader>mp", ":MarkdownPreviewToggle<CR>", "preview md" },
    },
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
      require("nvim-surround").setup({})
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

  -- nvim-colorizer: color label for hex codes
  {
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
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

  -- searchbox.nvim: searchbox for searching and replacing words
  -- {
  --   "VonHeikemen/searchbox.nvim",
  --   config = function()
  --     require("plugins.searchbox")
  --   end,
  --   dependencies = {
  --     { "MunifTanjim/nui.nvim" },
  --   },
  -- },

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
    "simrat39/rust-tools.nvim",
    ft = "rust",
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
        "<leader><leader>h",
        function()
          require("duck").hatch("❄️", 5)
          require("duck").hatch("❄️", 5)
          require("duck").hatch("❄️", 5)
          require("duck").hatch("❄️", 3)
          require("duck").hatch("❄️", 3)
        end,
      },
    },
    config = function()
      vim.keymap.set("n", "<leader><leader>r", function()
        require("duck").cook()
      end)
    end,
  },

  -- TODO: fork and customize
  {
    "phaazon/mind.nvim",
    branch = "v2.2",
    keys = {
      {
        "<leader>mdm",
        ":MindOpenMain<CR>",
      },
      {
        "<leader>mdp",
        function()
          require("nvim-rooter").rooter()
          require("mind").open_project(true)
        end,
      },
      {
        "<leader>mdc",
        ":MindClose<CR>",
      },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("mind").setup()
    end,
  },

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

  -- {
  --   "jcha0713/classy.nvim",
  --   keys = {
  --     { "<leader>ac", ":ClassyAddClass<CR>", desc = "Add class attr" },
  --     { "<leader>dc", ":ClassyRemoveClass<CR>", desc = "Remove class attr" },
  --     { "<leader>rc", ":ClassyResetClass<CR>", desc = "Reset class attr" },
  --   },
  -- },

  {
    "jcha0713/classy.nvim",
    dir = "~/jhcha/dev/2022/project/classy",
    dev = true,
    keys = {
      { "<leader>ac", ":ClassyAddClass<CR>", desc = "Add class attr" },
      { "<leader>dc", ":ClassyRemoveClass<CR>", desc = "Remove class attr" },
      { "<leader>rc", ":ClassyResetClass<CR>", desc = "Reset class attr" },
    },
  },
  {
    "gleam-lang/gleam.vim",
    ft = "gleam",
  },
  {
    "sourcegraph/sg.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = true,
    keys = {
      { "<leader>sg", ":SourcegraphSearch<CR>", desc = "Sourcegraph Search" },
      { "<M-z>", ":CodyToggle<CR>", desc = "Cody Toggle" },
      { "<M-c>", ":CodyChat<CR>", desc = "Cody Chat" },
    },
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
    "lukas-reineke/headlines.nvim",
    event = "VeryLazy",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true, -- or `opts = {}`
  },

  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>ol", ":Outline<CR>", desc = "Toggle outline" },
    },
    config = function()
      require("outline").setup({
        outline_items = {
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
    "kawre/leetcode.nvim",
    event = "BufEnter",
    build = ":TSUpdate html",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim", -- required by telescope
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      arg = "leetcode",
      lang = "javascript",
    },
  },
  {
    "pwntester/octo.nvim",
    event = "VeryLazy",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = true,
  },
}
