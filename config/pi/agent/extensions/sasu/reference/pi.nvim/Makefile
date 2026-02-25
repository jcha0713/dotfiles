# Makefile for pi.nvim tests

# Path to mini.test - can be overridden
MINI_TEST_PATH ?= deps/mini.test

# Neovim executable
NVIM ?= nvim

.PHONY: test deps clean test-verbose test-interactive

# Install mini.test as a dependency
deps:
	@mkdir -p deps
	@if [ ! -d "$(MINI_TEST_PATH)" ]; then \
		git clone --depth 1 https://github.com/echasnovski/mini.test.git $(MINI_TEST_PATH); \
	fi

# Run all tests
test: deps
	@$(NVIM) --headless --noplugin -u tests/minimal_init.lua -c "luafile scripts/run_tests.lua"

# Run tests with verbose output (same as test for now)
test-verbose: deps
	@$(NVIM) --headless --noplugin -u tests/minimal_init.lua -c "luafile scripts/run_tests.lua"

# Run tests interactively (opens Neovim for debugging)
test-interactive: deps
	@$(NVIM) -u tests/minimal_init.lua -c "lua require('mini.test').setup()" -c "lua MiniTest.run_file('tests/test_pi_commands.lua')"

# Clean dependencies
clean:
	rm -rf deps
