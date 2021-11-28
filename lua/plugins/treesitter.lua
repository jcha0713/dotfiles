require'nvim-treesitter.configs'.setup {
  ensure_installed = { 'html', 'css', 'javascript', 'svelte' },
  highlight = {
    enable = true,              -- false will disable the whole extension
  },
  indent = {
    enable = true,
  }
}
