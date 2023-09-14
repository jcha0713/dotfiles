return {
  "kyazdani42/nvim-tree.lua",
  keys = {
    { "<C-n>", ":NvimTreeToggle<CR>", desc = "Open NvimTree" },
  },
  config = function()
    require("nvim-tree").setup()
  end,
}
