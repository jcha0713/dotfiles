-- Minimal init.lua for testing pi.nvim
-- This is loaded by the child Neovim process during tests

-- Set up a minimal runtime path
vim.opt.runtimepath:append('.')

-- Add mini.test to runtimepath if it exists (for running via Makefile)
local mini_test_path = './deps/mini.test'
if vim.fn.isdirectory(mini_test_path) == 1 then
  vim.opt.runtimepath:append(mini_test_path)
end

-- Also check for mini.test in parent (if installed as part of mini.nvim)
if vim.fn.isdirectory('./deps/mini.nvim') == 1 then
  vim.opt.runtimepath:append('./deps/mini.nvim')
end

-- Add the local lua directory to package.path
package.path = package.path .. ';./lua/?.lua;./lua/?/init.lua'

-- Disable some UI elements for headless testing
vim.opt.termguicolors = false
vim.opt.background = 'light'

-- Set up a minimal environment
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Silence notifications during tests
vim.notify = function(msg, level, opts)
  -- Store notifications for test verification
  if not _G.__pi_test_notifications then
    _G.__pi_test_notifications = {}
  end
  table.insert(_G.__pi_test_notifications, { msg = msg, level = level })
end
