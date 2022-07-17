-- following options are the default
-- each of these are documented in `:help nvim-tree.OPTION_NAME`

require("nvim-tree").setup({
  -- disable_netrw = true,
  -- hijack_netrw = true,
  open_on_setup = false,
  respect_buf_cwd = false,
  ignore_ft_on_setup = {},
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
    height = 30,
    hide_root_folder = false,
    side = "left",
    mappings = {
      custom_only = false,
      list = {},
    },
  },
})
