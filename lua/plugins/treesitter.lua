require'nvim-treesitter.configs'.setup {
  ensure_installed = { 'html', 'css', 'javascript', 'typescript', 'svelte', 'lua' },
  highlight = {
    enable = true,              -- false will disable the whole extension
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
}
