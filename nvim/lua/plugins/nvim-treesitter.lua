return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    -- LOOKUP: https://github.com/nvim-treesitter/nvim-treesitter/issues/655
    vim.treesitter.language.register("bash", "zsh")

    local parser_configs =
      require("nvim-treesitter.parsers").get_parser_configs()

    parser_configs.norg_meta = {
      install_info = {
        url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
        files = { "src/parser.c" },
        branch = "main",
      },
    }

    parser_configs.norg_table = {
      install_info = {
        url = "https://github.com/nvim-neorg/tree-sitter-norg-table",
        files = { "src/parser.c" },
        branch = "main",
      },
    }

    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "astro",
        "css",
        "diff",
        "gleam",
        "go",
        "html",
        "bash",
        "http",
        "javascript",
        "json",
        "jsonc",
        "lua",
        "markdown",
        "markdown_inline",
        "norg",
        "norg_meta",
        "norg_table",
        "prisma",
        "rust",
        "scss",
        "svelte",
        "swift",
        "tsx",
        "typescript",
        "query",
        "vimdoc",
        "yaml",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      autotag = {
        enable = true,
      },
      rainbow = {
        enable = true,
        extended_mode = true,
      },
      -- query_linter = {
      --   enable = true,
      --   use_virtual_text = true,
      --   lint_events = { "BufWrite", "CursorHold" },
      -- },
    })
  end,
}
