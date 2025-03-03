return {
  "kawre/leetcode.nvim",
  event = "BufEnter",
  build = ":TSUpdate html",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim", -- required by telescope
    "MunifTanjim/nui.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    arg = "leetcode",
    lang = "javascript",
    theme = {
      ["normal"] = {
        fg = "#a390a2",
      },
    },
  },
  keys = {
    {
      "<leader><leader>r",
      ":Leet run<CR>",
      {
        desc = "Leetcode run",
      },
    },
  },
}
