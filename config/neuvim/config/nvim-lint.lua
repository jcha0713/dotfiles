require("lint").linters_by_ft = {
  javascript = { "oxlint" },
  typescript = { "oxlint" },
  javascriptreact = { "oxlint" },
  typescriptreact = { "oxlint" },
  nix = { "nix" },
}
vim.api.nvim_create_autocmd({
  "BufEnter",
  "BufWritePost",
  "TextChanged",
  "InsertLeave",
}, {
  group = vim.api.nvim_create_augroup("neuvim.lint", { clear = true }),
  callback = function()
    pcall(require, "lint.try_lint")
  end,
})
