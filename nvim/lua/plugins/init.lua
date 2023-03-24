return {
  -- neodev: For better lua lsp configuration
  { "folke/neodev.nvim", ft = "lua" },

  -- lua utils for neovim
  "nvim-lua/plenary.nvim",

  -- vim-startify: start screen
  { "mhinz/vim-startify", lazy = false },

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

  {
    "HiPhish/nvim-ts-rainbow2",
    event = "VeryLazy",
  },

  -- playground for treesitter
  {
    "nvim-treesitter/playground",
    cmd = "TSPlaygroundToggle",
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
    ft = { "html", "javascriptreact", "typescriptreact" },
    -- "jcha0713/emmet-vim",
    init = function()
      vim.g["user_emmet_leader_key"] = "<C-e>"
      vim.g["user_emmet_settings"] = [[{'astro': {'extends' : 'html',}}]]
    end,
  },

  -- diffview.nvim: git diff view
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
  },
  --
  -- trouble.nvim: error fix using quickfix list
  {
    "folke/trouble.nvim",
    event = "VeryLazy",
    dependencies = "kyazdani42/nvim-web-devicons",
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

  -- vim-rooter: changes working directory when opening a file
  -- {
  --   "airblade/vim-rooter",
  --   event = "VeryLazy",
  --   config = function()
  --     vim.g.rooter_patterns = {
  --       "!.git/worktrees", -- without this line, git commit in neogit does not work well because vim-rooter is changing the cwd
  --       ".git",
  --     }
  --
  --     vim.g.rooter_change_directory_for_non_project_files = "current"
  --   end,
  -- },

  {
    "notjedi/nvim-rooter.lua",
    event = "VeryLazy",
  },

  -- searchbox.nvim: searchbox for searching and replacing words
  {
    "VonHeikemen/searchbox.nvim",
    config = function()
      require("plugins.searchbox")
    end,
    dependencies = {
      { "MunifTanjim/nui.nvim" },
    },
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
  --

  -- easy jumps
  {
    "ggandor/leap.nvim",
    event = "BufRead",
    config = function()
      require("leap").add_default_mappings()

      vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
    end,
  },

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
          require("duck").hatch("💕", 5)
          require("duck").hatch("💕", 5)
          require("duck").hatch("💕", 5)
        end,
      },
    },
    config = function()
      vim.keymap.set("n", "<leader><leader>r", function()
        require("duck").cook()
      end)
    end,
  },

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
  --   "Exafunction/codeium.vim",
  --   event = "VeryLazy",
  --   init = function()
  --     vim.g.codeium_filetypes = {
  --       nim = false,
  --       markdown = false,
  --     }
  --   end,
  --   config = function()
  --     vim.keymap.set("i", "<C-c>", function()
  --       return vim.fn["codeium#Accept"]()
  --     end, { expr = true })
  --     -- vim.keymap.set("i", "<c-;>", function()
  --     --   return vim.fn["codeium#CycleCompletions"](1)
  --     -- end, { expr = true })
  --     -- vim.keymap.set("i", "<c-,>", function()
  --     --   return vim.fn["codeium#CycleCompletions"](-1)
  --     -- end, { expr = true })
  --     vim.keymap.set("i", "<c-x>", function()
  --       return vim.fn["codeium#Clear"]()
  --     end, { expr = true })
  --   end,
  -- },

  {
    "zbirenbaum/copilot.lua",
    event = "BufRead",
    build = ":Copilot auth",
    opts = {
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<C-c>",
        },
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
    end,
  },

  {
    "jcha0713/classy.nvim",
    keys = {
      { "<leader>ac", ":ClassyAddClass<CR>", desc = "Add class attr" },
      { "<leader>dc", ":ClassyRemoveClass<CR>", desc = "Remove class attr" },
      { "<leader>rc", ":ClassyResetClass<CR>", desc = "Reset class attr" },
    },
  },
}
