local api = vim.api

api.nvim_set_var("lsp_servers", {
  "astro",
  "bashls",
  "cssls",
  -- "cssmodules_ls",
  -- "eslint",
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
  -- "solang",
  "lua_ls",
  "svelte",
  "tailwindcss",
  "tsserver",
  -- "unocss",
})

-- NOTE: convert lsp server name to corresponding filename
-- Not sure if this is efficient
-- https://github.com/nvim-tree/nvim-web-devicons/blob/b427ac5f9dff494f839e81441fb3f04a58cbcfbc/lua/nvim-web-devicons.lua#L42
api.nvim_set_var("filenames", {
  ["astro"] = "astro",
  ["bashls"] = "sh",
  ["cssls"] = "css",
  ["gopls"] = "go",
  ["html"] = "html",
  ["jsonls"] = "json",
  ["marksman"] = "markdown",
  ["nimls"] = "nim",
  ["prismals"] = "prisma",
  ["pyright"] = "py",
  ["rust_analyzer"] = "rs",
  ["lua_ls"] = "lua",
  ["svelt"] = "svelte",
  ["tsserver"] = "ts",
})

api.nvim_set_var("lsp_linters", {
  "quick-lint-js",
  "vale",
})

api.nvim_set_var("lsp_formatters", {
  "dprint",
  "prettier",
  "prettierd",
  "shfmt",
  "stylua",
})

api.nvim_set_var("extras", {
  "biome",
})
