local null_ls = require("null-ls")
local b = null_ls.builtins

local eslint_opts = {
  condition = function(utils)
    return utils.root_has_file(".eslintrc.*")
  end,
  diagnostics_format = "#{m} [#{c}]",
}

local sources = {
  b.diagnostics.eslint_d.with(eslint_opts),
  -- b.formatting.eslint_d.with(eslint_opts),
  b.code_actions.eslint_d.with(eslint_opts),
  b.formatting.stylua,
  -- b.formatting.prettier.with({
  --   prefer_local = "node_modules/.bin",
  --   filetypes = {
  --     "html",
  --     "astro",
  --     "json",
  --     "jsonc",
  --     "svelte",
  --     "markdown",
  --     "css",
  --     "javascript",
  --     "javascriptreact",
  --     "typescript",
  --     "typescriptreact",
  --   },
  -- }),
  b.formatting.prettierd.with({
    env = {
      PRETTIERD_DEFAULT_CONFIG = vim.fn.expand(
        "$HOME/.config/nvim/utils/linter-config/.prettierrc.json"
      ),
    },
    filetypes = {
      "html",
      "astro",
      "json",
      "jsonc",
      "svelte",
      "markdown",
      "css",
      "scss",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
  }),
  b.hover.dictionary,
}

local M = {}
M.setup = function(on_attach)
  null_ls.setup({
    -- debug = true,
    sources = sources,
    on_attach = on_attach,
  })
end

return M
