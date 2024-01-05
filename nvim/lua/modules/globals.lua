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
  "null-ls",
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

api.nvim_set_var("linters", {
  "quick-lint-js",
})

api.nvim_set_var("formatters", {
  "dprint",
  "prettier",
  "stylua",
})
