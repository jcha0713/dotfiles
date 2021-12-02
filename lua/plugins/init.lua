local fn = vim.fn
local execute = vim.api.nvim_command

-- Auto install packer.nvim if not exists
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end
vim.cmd [[packadd packer.nvim]]
vim.cmd 'autocmd BufWritePost plugins.lua PackerCompile' -- Auto compile when there are changes in plugins.lua


-- Plugins

return require('packer').startup({
    function (use)
      -- Packer manages plugins
      use { 'wbthomason/packer.nvim', opt = true }

      -- By junegunn
      -- Seoul256 color scheme
      use {
        'junegunn/seoul256.vim',
        config = function ()
          vim.g.seoul256_background = 236
        end
      }

      -- rainbow_parentheses: colorful parenthesis (!)
      use {
        'junegunn/rainbow_parentheses.vim',
        config = function ()
          require 'plugins.rainbow_parentheses'
        end
      }

      -- Goyo + limelight: for ultra focus mode
      use {
        'junegunn/goyo.vim',
        config = function ()
          vim.cmd [[colo seoul256]]
        end
      }
      use {
        'junegunn/limelight.vim',
        config = function ()
          vim.api.nvim_command([[
            autocmd! User GoyoEnter Limelight
            autocmd! User GoyoLeave Limelight!
          ]])
        end
      }

      -- copilot: copi
      --[[
      use {
        'github/copilot.vim',
      }
      ]]

      -- luasnip: snippets for autocompletion
      use {
        'L3MON4D3/Luasnip',
        config = function ()
          require 'plugins.luasnip'
        end
      }

      -- nvim-cmp: manages snippets
      use {
        'hrsh7th/nvim-cmp',
        config = function ()
          require 'plugins.cmp'
        end,
        requires = {
          'hrsh7th/cmp-nvim-lsp',
          'hrsh7th/cmp-path',
          'hrsh7th/cmp-cmdline',
          'saadparwaiz1/cmp_luasnip',
          'tamago324/nlsp-settings.nvim',
          'onsails/lspkind-nvim'
        }
      }

      -- cmp-fuzzy-buffer: buffer source using fuzzy
      use {
        'tzachar/cmp-fuzzy-buffer',
        requires = { 'hrsh7th/nvim-cmp', 'tzachar/fuzzy.nvim' }
      }

      -- nvim-lspconfig: lsp configuration
      use {
        'neovim/nvim-lspconfig',
        requires = {
          'jose-elias-alvarez/null-ls.nvim',
          'jose-elias-alvarez/nvim-lsp-ts-utils',
        },
        config = function ()
          require 'modules.lsp'
        end
      }

      -- vim-illuminate: find occurrences
      use {
        'RRethy/vim-illuminate',
        config = function ()
          require 'plugins.illuminate'
        end
      }

      -- vim-surround: easily change surrounding tags
      use {
        'tpope/vim-surround'
      }

      -- schemastore: access to the SchemaStore catalog
      use {
        'b0o/schemastore.nvim'
      }

      -- Dashboard: start page
      use {
        'glepnir/dashboard-nvim',
        config = function ()
          require "plugins.dashboard"
        end
      }

      -- NvimTree: file explore
      use {
        'kyazdani42/nvim-tree.lua',
        config = function ()
          require 'plugins.nvim-tree'
        end
      }

      -- lualine: better status line
      use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true },
        config = function ()
          require 'plugins.lualine'
        end
      }

      -- Bufferline: bufferline management
      use {
        'akinsho/bufferline.nvim',
        requires = 'kyazdani42/nvim-web-devicons',
        config = function ()
          require 'plugins.bufferline'
        end
      }

      -- Telescope family
      -- telescope: file finder / explorer
      use {
        'nvim-telescope/telescope.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = function ()
          require 'plugins.telescope'
        end
      }

      use {
        'BurntSushi/ripgrep'
      }
      use {
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'make'
      }
      use {
        'tzachar/fuzzy.nvim',
        requires = {'hrsh7th/nvim-cmp', 'tzachar/fuzzy.nvim'}
      }

      -- autopairs: paring brackets/braces automatically
      use {
        'windwp/nvim-autopairs',
        config = function ()
          require 'plugins.autopairs'
        end
      }

      -- autotag: auto close the tag using treesitter
      use {
        'windwp/nvim-ts-autotag',
      }

      -- Treesitter: more language syntaxes
       use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function ()
          require 'plugins/treesitter'
        end
      }

      -- neoformat: ultimate formatter
      use {
        'sbdchd/neoformat'
      }

      -- neoscroll: enables smooth scrolling
      use {
        'karb94/neoscroll.nvim',
        config = function ()
          require 'plugins.neoscroll'
        end
      }

      -- nvim-colorizer: color label for hex codes
      use {
        'norcalli/nvim-colorizer.lua',
        config = function ()
          require 'plugins.colorizer'
        end
      }

      -- project-nvim: project management plugin
      use {
        'ahmedkhalf/project.nvim',
        config = function ()
          require 'plugins.project_nvim'
        end
      }

      -- emmet-vim: support for emmet
      use {
        'mattn/emmet-vim',
        config = function ()
          require 'plugins.emmet'
        end
      }

      -- comment.nvim: comment out lines
      use {
        'numToStr/Comment.nvim',
        config = function()
            require 'plugins.comment'
        end
      }



    end
})
