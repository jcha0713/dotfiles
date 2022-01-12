require("project_nvim").setup {
  exclude_dirs = { "~/*", "~/.config/*" },
  show_hidden = false,
  detection_method = { "lsp", "pattern" },
  silent_chdir = false,
  patterns = {
    "prettierrc.json",
    "tsconfig.json",
    "stylua.toml",
    "package.json",
    -- "eslintrc.json",
  },
}
