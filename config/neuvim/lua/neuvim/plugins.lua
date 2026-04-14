return {
  { "nvim-treesitter/nvim-treesitter", name = "treesitter" },
  "neovim/nvim-lspconfig",
  "nvim-lua/plenary.nvim",

  -- Colorscheme
  "vague-theme/vague.nvim",
  "e-ink-colorscheme/e-ink.nvim",
  "kungfusheep/mfd.nvim",

  "mikavilpas/yazi.nvim",
  "comfysage/artio.nvim",

  "nvim-mini/mini.icons",
  { "nvim-mini/mini.pairs", event = "BufRead" },
  { "nvim-mini/mini.diff" },

  { "MeanderingProgrammer/render-markdown.nvim", event = "BufEnter" },
  { "bassamsdata/namu.nvim", event = "BufEnter" },

  "stevearc/conform.nvim",
  { "mfussenegger/nvim-lint", name = "lint" },

  { "saghen/blink.cmp", name = "blink", version = vim.version.range("^1") },

  { "cursortab/cursortab.nvim", name = "cursortab" },

  { "yorickpeterse/nvim-jump", name = "jump", event = "BufEnter" },
}
