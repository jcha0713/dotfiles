return {
  { "nvim-lua/plenary.nvim", branch = "master" },

  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },

  {
    "tzachar/cmp-fuzzy-buffer",
    event = "VeryLazy",
    dependencies = { "hrsh7th/nvim-cmp", "tzachar/fuzzy.nvim" },
  },

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

  {
    "mattn/emmet-vim",
    event = "BufEnter",
    ft = { "html", "javascriptreact", "typescriptreact" },
    init = function()
      vim.g["user_emmet_leader_key"] = "<C-,>"
      vim.g["user_emmet_settings"] = [[{'astro': {'extends' : 'html',}}]]
    end,
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- Recommended
    ft = { "rust" },
  },

  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    version = "v0.3.0",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup()
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
    "otavioschwanck/telescope-cmdline-word.nvim",
    event = "BufEnter",
    opts = {
      add_mappings = true, -- add <tab> mapping automatically
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
    "aznhe21/actions-preview.nvim",
    event = "BufEnter",
    -- dependencies = { "stevearc/dressing.nvim" },
    config = function()
      require("actions-preview").setup({
        backend = { "telescope", "snacks" },

        highlight_command = {
          require("actions-preview.highlight").delta(),
        },

        telescope = {
          sorting_strategy = "ascending",
          layout_strategy = "vertical",
          layout_config = {
            width = 0.9,
            height = 0.5,
            prompt_position = "top",
            preview_cutoff = 20,
            preview_height = function(_, _, max_lines)
              return max_lines - 15
            end,
          },
        },
      })
    end,
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
      highlight_duration = 400,
    },
  },

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

  {
    "Sebastian-Nielsen/better-type-hover",
    event = "VeryLazy",
    ft = { "typescript", "typescriptreact" },
    config = function()
      require("better-type-hover").setup({
        openTypeDocKeymap = "H",
      })
    end,
  },

  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has("nvim-0.10.0") == 1,
  },

  {
    "echasnovski/mini.align",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("mini.align").setup()
    end,
  },

  {
    "dmmulroy/tsc.nvim",
    event = "VeryLazy",
    opts = {
      use_trouble_qflist = true,
    },
  },

  {
    "axkirillov/unified.nvim",
    event = "VeryLazy",
    config = function()
      require("unified").setup()
    end,
  },

  {
    "developedbyed/marko.nvim",
    event = "VeryLazy",
    config = function()
      require("marko").setup({
        width = 100,
        height = 100,
        border = "rounded",
        title = " Marks ",
        default_keymap = "`",
      })
    end,
  },

  {
    "kosayoda/nvim-lightbulb",
    event = "VeryLazy",
    config = function()
      require("nvim-lightbulb").setup({
        autocmd = { enabled = true },
        sign = {
          enabled = false,
        },
        status_text = {
          enabled = true,
          -- Text to set if a lightbulb is available.
          text = "💡",
          lens_text = "🔎",
          -- Text to set if a lightbulb is unavailable.
          text_unavailable = "",
        },
      })
    end,
  },

  {
    "sourcegraph/amp.nvim",
    branch = "main",
    lazy = false,
    opts = { auto_start = true, log_level = "info" },
  },

  {
    "sudo-tee/opencode.nvim",
    enabled = false,
    event = "VeryLazy",
    config = function()
      require("opencode").setup({})
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          anti_conceal = { enabled = false },
          file_types = { "markdown", "opencode_output" },
        },
        ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
      },
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
    },
  },

  {
    dir = "~/.pi/agent/extensions/neovim",
    event = "VeryLazy",
    config = function()
      require("pi-nvim").setup()

      vim.keymap.set(
        "n",
        "<leader>po",
        require("pi-nvim").open,
        { desc = "Open Pi" }
      )
      vim.keymap.set(
        "n",
        "<leader>pc",
        require("pi-nvim").close,
        { desc = "Close Pi" }
      )
      vim.keymap.set(
        "n",
        "<leader>pp",
        require("pi-nvim").toggle,
        { desc = "Toggle Pi" }
      )
    end,
  },
}
