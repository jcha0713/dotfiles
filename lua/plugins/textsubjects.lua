require'nvim-treesitter.configs'.setup {
    textsubjects = {
        enable = true,
        keymaps = {
            ['<CR>'] = 'textsubjects-smart',
            [';'] = 'textsubjects-container-outer',
        }
    },
}
