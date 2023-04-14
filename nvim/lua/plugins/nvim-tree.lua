return {
  "kyazdani42/nvim-tree.lua",
  keys = {
    { "<C-n>", ":NvimTreeToggle<CR>", desc = "Open NvimTree" },
  },
  config = function()
    require("nvim-tree").setup({
      -- disable_netrw = true,
      -- hijack_netrw = true,
      respect_buf_cwd = false,
      open_on_tab = false,
      hijack_cursor = false,
      update_cwd = true,
      hijack_directories = {
        enable = true,
        auto_open = true,
      },
      diagnostics = {
        enable = false,
        icons = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        },
      },
      update_focused_file = {
        enable = true,
        update_cwd = true,
      },
      filters = {
        dotfiles = false,
        custom = {},
      },
      actions = {
        open_file = {
          resize_window = true,
        },
      },
      view = {
        width = 30,
        hide_root_folder = false,
        side = "left",
        mappings = {
          custom_only = false,
          list = {},
        },
      },
    })
  end,
}
