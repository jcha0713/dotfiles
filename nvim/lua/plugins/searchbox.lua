return {
  "VonHeikemen/searchbox.nvim",
  keys = {
    { "<M-/>", { ":SearchBoxIncSearch<CR>", mode = "x" } },
    { "<M-/>", ":SearchBoxIncSearch<CR>" },
    { "<leader>rp", { ":SearchBoxReplace<CR>", mode = "x" } },
  },
  config = function()
    require("searchbox").setup({
      defaults = {
        show_matches = true,
      },
      popup = {
        win_options = {
          winhighlight = "Normal:Normal,FloatBorder:Normal",
        },
      },
      hooks = {
        after_mount = function(input)
          local opts = { buffer = input.bufnr }

          -- <C-n> and <C-p> to go to next/prev item
          vim.keymap.set("i", "<C-n>", "<Plug>(searchbox-next-match)", opts)
          vim.keymap.set("i", "<C-p>", "<Plug>(searchbox-prev-match)", opts)
        end,
      },
    })
  end,
  dependencies = {
    { "MunifTanjim/nui.nvim" },
  },
}
