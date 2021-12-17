require("project_nvim").setup {
  exclude_dirs = { "~/.config/*" },
  show_hidden = false,
  detection_method = { "lsp", "pattern" },
  patterns = { ".git", ".package.json", "stylua.toml", "tsconfig.json" },
}
