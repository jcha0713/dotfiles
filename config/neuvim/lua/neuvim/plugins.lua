return {
  { "nvim-treesitter/nvim-treesitter", name = "treesitter" },
  "neovim/nvim-lspconfig",
  "nvim-lua/plenary.nvim",

  -- Colorscheme
  "vague-theme/vague.nvim",
  "e-ink-colorscheme/e-ink.nvim",
  "kungfusheep/mfd.nvim",

  -- UI
  { "MeanderingProgrammer/render-markdown.nvim", event = "BufEnter" },

  -- Navigation
  "mikavilpas/yazi.nvim",
  "comfysage/artio.nvim",
  { "bassamsdata/namu.nvim", event = "BufEnter" },
  { "yorickpeterse/nvim-jump", name = "jump", event = "BufEnter" },

  -- Mini
  "nvim-mini/mini.icons",
  { "nvim-mini/mini.pairs", event = "BufRead" },
  { "nvim-mini/mini.diff", event = "BufEnter" },
  { "nvim-mini/mini.visits", event = "BufEnter" },
  { "nvim-mini/mini.surround", event = "BufEnter" },

  -- Format/Lint
  "stevearc/conform.nvim",
  { "mfussenegger/nvim-lint", name = "lint" },

  -- Completion
  { "saghen/blink.cmp", name = "blink", version = vim.version.range("^1") },
  { "cursortab/cursortab.nvim", name = "cursortab" },
}
