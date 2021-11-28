local utils = require('modules.utils')

vim.g.mapleader = ' '

-- easy keys for ESC
utils.map('i', 'jj', '<ESC>')

-- paste with Enter key
utils.map('n', '<CR>', 'o<ESC>k')

-- no hl
utils.map('n', '<Leader>h', ':set hlsearch!<CR>')

-- explorer
utils.map('n', '<C-n>', ':NvimTreeToggle<CR>')

-- Enter Goyo
utils.map('n', '<Leader>g', ':Goyo<CR>')

-- source lua file
utils.map('n', '<Leader>s', ':luafile %<CR>')

-- better window movement
utils.map('n', '<C-h>', '<C-w>h')
utils.map('n', '<C-j>', '<C-w>j')
utils.map('n', '<C-k>', '<C-w>k')
utils.map('n', '<C-l>', '<C-w>l')

-- Switch buffers
utils.map('n', '<S-k>', ':BufferLineCycleNext<CR>')
utils.map('n', '<S-j>', ':BufferLineCyclePrev<CR>')
utils.map('n', '<Leader>x', ':bdelete<CR>')

-- Rainbow Parentheses
utils.map('n', '<Leader>p', ':RainbowParentheses!!<CR>')

-- Clear highlight
utils.map('n', '<Leader>n', '<cmd>noh<CR>')

--Telescope
utils.map('n', '<Leader>ff', ':Telescope find_files<CR>')
utils.map('n', '<Leader>fg', ':Telescope live_grep<CR>')
utils.map('n', '<Leader>fb', ':Telescope buffers<CR>')
utils.map('n', '<Leader>fr', ':Telescope projects<CR>')
