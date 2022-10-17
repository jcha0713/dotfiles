local fn = vim.fn
local execute = vim.api.nvim_command

-- Auto install packer.nvim if not exists
local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  execute(
    "!git clone https://github.com/wbthomason/packer.nvim " .. install_path
  )
end

vim.cmd([[packadd packer.nvim]])
vim.cmd("autocmd BufWritePost plugins.lua PackerCompile") -- Auto compile when there are changes in plugins.lua

-- Plugins

return require("packer").startup({
  function(use)
    -- Packer manages plugins
    use({ "wbthomason/packer.nvim", opt = true })

    -- lua-dev: For better lua lsp configuration
    use("folke/lua-dev.nvim")

    -- vim-startify: start screen
    use({
      "mhinz/vim-startify",
    })

    -- markdown-preview: preview for *.md
    use({
      "iamcco/markdown-preview.nvim",
      run = "cd app && npm install",
      setup = function()
        vim.g.mkdp_filetypes = { "markdown" }
      end,
      ft = { "markdown", "md" },
      cmd = "MarkdownPreview",
    })

    -- Gruvbox-flat: colorscheme
    -- use({
    --   "eddyekofo94/gruvbox-flat.nvim",
    -- })
    use({ "rebelot/kanagawa.nvim" })

    -- neorg: todo list
    use({
      "nvim-neorg/neorg",
      config = function()
        require("plugins.neorg")
      end,
    })

    -- nvim-peekup: pickup from register
    use({
      "gennaro-tedesco/nvim-peekup",
      keys = { { "n", '""' } },
    })

    -- friendly snippets: snippets for autocompletion
    use({
      "rafamadriz/friendly-snippets",
    })

    -- luasnip: snippets for autocompletion
    use({
      "L3MON4D3/Luasnip",
      config = function()
        require("plugins.luasnip")
      end,
    })

    -- nvim-cmp: manages snippets
    use({
      "hrsh7th/nvim-cmp",
      config = function()
        require("plugins.cmp")
      end,
      requires = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "saadparwaiz1/cmp_luasnip",
        "tamago324/nlsp-settings.nvim",
        "onsails/lspkind-nvim",
        "octaltree/cmp-look",
        -- "jcha0713/cmp-tw2css",
      },
    })

    -- cmp-fuzzy-buffer: buffer source using fuzzy
    use({
      "tzachar/cmp-fuzzy-buffer",
      requires = { "hrsh7th/nvim-cmp", "tzachar/fuzzy.nvim" },
    })

    -- nvim-lspconfig: lsp configuration
    use({
      "neovim/nvim-lspconfig",
      requires = {
        "jose-elias-alvarez/null-ls.nvim",
        "jose-elias-alvarez/typescript.nvim",
      },
      config = function()
        require("modules.lsp")
      end,
    })

    -- lsp-signature: signature help
    use({
      "ray-x/lsp_signature.nvim",
      config = function()
        require("plugins.lsp_signature")
      end,
    })

    -- vim-illuminate: find occurrences
    use({
      "RRethy/vim-illuminate",
      config = function()
        require("plugins.illuminate")
      end,
    })

    -- nvim-surround: nvim version of vim-surround
    use({
      "kylechui/nvim-surround",
      config = function()
        require("plugins.nvim-surround")
      end,
    })

    -- schemastore: access to the SchemaStore catalog
    use({
      "b0o/schemastore.nvim",
    })

    -- NvimTree: file explore
    use({
      "kyazdani42/nvim-tree.lua",
      config = function()
        require("plugins.nvim-tree")
      end,
    })

    -- lualine: better status line
    use({
      "nvim-lualine/lualine.nvim",
      requires = { { "kyazdani42/nvim-web-devicons", opt = true } },
      config = function()
        require("plugins.lualine")
      end,
    })

    -- Telescope family
    -- telescope: file finder / explorer
    use({
      "nvim-telescope/telescope.nvim",
      requires = "nvim-lua/plenary.nvim",
      config = function()
        require("plugins.telescope")
      end,
    })

    use({
      "nvim-telescope/telescope-file-browser.nvim",
    })

    use({
      "BurntSushi/ripgrep",
    })

    use({
      "nvim-telescope/telescope-fzf-native.nvim",
      run = "make",
    })

    use({
      "tzachar/fuzzy.nvim",
      requires = { "hrsh7th/nvim-cmp", "tzachar/fuzzy.nvim" },
    })

    -- autopairs: paring brackets/braces automatically
    use({
      "windwp/nvim-autopairs",
      config = function()
        require("plugins.autopairs")
      end,
    })

    -- autotag: auto close the tag using treesitter
    use({
      "windwp/nvim-ts-autotag",
    })

    -- Treesitter: more language syntaxes
    use({
      "nvim-treesitter/nvim-treesitter",
      run = ":TSUpdate",
      config = function()
        require("plugins/treesitter")
      end,
    })

    -- playground for treesitter
    use({
      "nvim-treesitter/playground",
    })

    -- Treesitter textobjects: more text objects to easily select them
    use({
      "nvim-treesitter/nvim-treesitter-textobjects",
      config = function()
        require("plugins/textobjects")
      end,
    })

    -- nvim-treesitter-textsubjects: new way to select text objects
    use({
      "RRethy/nvim-treesitter-textsubjects",
      config = function()
        require("plugins/textsubjects")
      end,
    })

    -- neogen: docstring generator
    use({
      "danymat/neogen",
      config = function()
        require("plugins.neogen")
      end,
      requires = "nvim-treesitter/nvim-treesitter",
      -- Uncomment next line if you want to follow only stable versions
      -- tag = "*"
    })

    -- neoscroll: enables smooth scrolling
    use({
      "karb94/neoscroll.nvim",
      config = function()
        require("plugins.neoscroll")
      end,
    })

    -- nvim-colorizer: color label for hex codes
    use({
      "norcalli/nvim-colorizer.lua",
      config = function()
        require("plugins.colorizer")
      end,
    })

    -- emmet-vim: support for emmet
    use({
      "mattn/emmet-vim",
      config = function()
        require("plugins.emmet")
      end,
    })

    -- Glow: markdown preview
    use({
      "ellisonleao/glow.nvim",
      config = function()
        require("glow").setup({
          style = "dark",
          width = 120,
          border = "rounded",
        })
      end,
      cmd = "Glow",
    })

    -- comment.nvim: comment out lines
    use({
      "numToStr/Comment.nvim",
      config = function()
        require("plugins.comment")
      end,
    })

    use({
      "TovarishFin/vim-solidity",
    })

    -- hop.nvim: flexible cursor movement
    use({
      "phaazon/hop.nvim",
      branch = "master",
      config = function()
        require("plugins.hop")
      end,
    })

    -- diffview.nvim: git diff view
    use({
      "sindrets/diffview.nvim",
      requires = "nvim-lua/plenary.nvim",
      config = function()
        require("plugins.diffview")
      end,
    })

    -- toggleterm.nvim: terminal in neovim
    use({
      "akinsho/toggleterm.nvim",
      tag = "v2.*",
      config = function()
        require("plugins.toggleterm")
      end,
    })

    -- neogit.nvim: git in neovim
    -- use({
    --   "TimUntersberger/neogit",
    --   requires = "nvim-lua/plenary.nvim",
    --   config = function()
    --     require("plugins.neogit")
    --   end,
    -- })

    -- trouble.nvim: error fix using quickfix list
    use({
      "folke/trouble.nvim",
      requires = "kyazdani42/nvim-web-devicons",
      config = function()
        require("plugins.trouble")
      end,
    })

    -- vim-rooter: changes working directory when opening a file
    use({
      "airblade/vim-rooter",
      config = function()
        require("plugins.vim-rooter")
      end,
    })

    -- searchbox.nvim: searchbox for searching and replacing words
    use({
      "VonHeikemen/searchbox.nvim",
      config = function()
        require("plugins.searchbox")
      end,
      requires = {
        { "MunifTanjim/nui.nvim" },
      },
    })

    -- Latex in markdown
    use({
      "jbyuki/nabla.nvim",
      ft = { "markdown", "md" },
      config = function()
        require("plugins.nabla")
      end,
    })

    -- Markdown
    use({
      "jakewvincent/mkdnflow.nvim",
      config = function()
        require("plugins.mkdnflow")
      end,
    })

    -- Rust
    use({
      "simrat39/rust-tools.nvim",
    })

    -- Profiling
    use({
      "dstein64/vim-startuptime",
      cmd = "StartupTime",
      config = [[vim.g.startuptime_tries = 10]],
    })

    -- Optimizing startuptime
    use({ "lewis6991/impatient.nvim" })

    -- icons for extensions
    use({
      "kyazdani42/nvim-web-devicons",
      config = function()
        require("plugins.nvim-web-devicons")
      end,
    })

    -- display keymap info
    use({
      "folke/which-key.nvim",
      config = function()
        require("plugins.which-key")
      end,
    })

    -- web bookmarks
    use({
      "dhruvmanila/telescope-bookmarks.nvim",
      tag = "*",
    })

    -- crates.io
    use({
      "saecki/crates.nvim",
      event = { "BufRead Cargo.toml" },
      tag = "v0.3.0",
      requires = { "nvim-lua/plenary.nvim" },
      config = function()
        require("crates").setup()
      end,
    })

    -- cosmic-ui
    use({
      "CosmicNvim/cosmic-ui",
      requires = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
      config = function()
        require("plugins.cosmic-ui")
      end,
    })
  end,
})
