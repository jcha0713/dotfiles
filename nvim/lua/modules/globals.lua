local api = vim.api

api.nvim_set_var("lsp_servers", {
  "astro",
  "bashls",
  "cssls",
  -- "cssmodules_ls",
  "eslint",
  "gleam",
  "gopls",
  "html",
  "jsonls",
  "nimls",
  -- "null-ls",
  "marksman",
  "prismals",
  "pyright",
  "rust_analyzer",
  "solang",
  "lua_ls",
  "svelte",
  "tailwindcss",
  "tsserver",
  -- "unocss",
})

api.nvim_set_var("lsp_linters", {
  "quick-lint-js",
  "vale"
})

api.nvim_set_var("lsp_formatters", {
  "dprint",
  "prettier",
  "stylua",
})

api.nvim_set_var("extras", {
  "biome",
})

