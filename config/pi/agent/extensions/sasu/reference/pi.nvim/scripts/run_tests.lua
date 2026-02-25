-- Test runner for pi.nvim using mini.test
-- Run with: nvim --headless -u tests/minimal_init.lua -c "luafile scripts/run_tests.lua"

-- Ensure mini.test is available
local mini_test_path = './deps/mini.test'
if vim.fn.isdirectory(mini_test_path) == 1 then
  vim.opt.runtimepath:append(mini_test_path)
end

local MiniTest = require('mini.test')

-- Configure mini.test
MiniTest.setup({
  -- Use stdout reporter for CI
  execute = {
    reporter = MiniTest.gen_reporter.stdout({
      group_depth = 2,
    }),
  },
})

-- Run the test file
MiniTest.run_file('tests/test_pi_commands.lua')

-- Exit with appropriate code
vim.cmd('qa!')
