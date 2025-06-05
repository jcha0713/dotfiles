return {
  "nvim-tree/nvim-tree.lua",
  enabled = false,
  keys = {
    { "<C-n>", ":NvimTreeToggle<CR>", desc = "Open NvimTree" },
  },
  config = function()
    require("nvim-tree").setup({
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      view = {
        centralize_selection = true,
        side = "right",
      },
      renderer = {
        highlight_bookmarks = "name",
      },
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      modified = {
        enable = true,
      },
    })
  end,
}
