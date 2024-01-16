return {
  "nvim-tree/nvim-tree.lua",
  keys = {
    { "<C-n>", ":NvimTreeToggle<CR>", desc = "Open NvimTree" },
  },
  config = function()
    require("nvim-tree").setup({
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      view = {
        side = "right",
      },
    })
  end,
}
