local null_ls = require "null-ls"
local b = null_ls.builtins

local eslint_opts = {
  condition = function(utils)
    return utils.root_has_file ".eslintrc.*"
  end,
  diagnostics_format = "#{m} [#{c}]",
}

local sources = {
  --[[
    b.formatting.prettier.with({
        disabled_filetypes = { "typescript", "typescriptreact" },
    }),
    ]]
  b.diagnostics.eslint_d.with(eslint_opts),
  b.formatting.eslint_d.with(eslint_opts),
  b.code_actions.eslint_d.with(eslint_opts),
  b.formatting.stylua,
  b.formatting.prettierd.with {
    filetypes = {
      "html",
      "astro",
      "json",
      "jsonc",
      "svelte",
      "markdown",
      "css",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
  },
  b.formatting.trim_whitespace.with { filetypes = { "tmux", "teal", "zsh" } },
  b.formatting.shfmt,
  -- b.diagnostics.markdownlint,
  b.diagnostics.teal,
  b.diagnostics.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
  b.code_actions.gitsigns,
  b.hover.dictionary,
}

local M = {}
M.setup = function(on_attach)
  null_ls.setup {
    -- debug = true,
    sources = sources,
    on_attach = on_attach,
  }
end

return M
