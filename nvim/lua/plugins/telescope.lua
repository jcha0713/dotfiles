local ignore_files = {
  "node_modules/.*",
  ".git/.*",
  ".yarn/.*",
  ".neuron/*",
  "fonts/*",
  "icons/*",
  "images/*",
  "dist/*",
  "build/*",
  "yarn.lock",
  "package%-lock.json",
  "%.svg",
  "%.png",
  "%.jpeg",
  "%.jpg",
  "%.webp",
  "%.ico",
  "data/lua%-language%-server",
  ".DS_Store",
  "/EmmyLua.spoon/annotations/*",
}

local picker_opt = {
  defaults = {
    file_ignore_patterns = ignore_files,
  },
}

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "BurntSushi/ripgrep",
  },
  cmd = "Telescope",
  keys = {
    {
      "<leader><leader>t",
      ":Telescope builtin<CR>",
      desc = "Telescope builtins",
    },
    {
      "<leader>ff",
      ":Telescope find_files<CR>",
      desc = "Telescope find files",
    },
    {
      "<leader>gr",
      ":Telescope live_grep<CR>",
      desc = "Telescope live grep",
    },
    { "<leader>bf", ":Telescope buffers<CR>", desc = "Telescope buffers" },
    {
      "<leader>of",
      ":Telescope old_files<CR>",
      desc = "Telescope old files",
    },
    { "<leader>cm", ":Telescope commands<CR>", desc = "Telescope commands" },
    { "<leader>km", ":Telescope keymaps<CR>", desc = "Telescope  keymaps" },
  },
  config = function()
    local actions = require("telescope.actions")
    local trouble = require("trouble.providers.telescope")

    require("telescope").setup({
      pickers = picker_opt,
      defaults = {
        file_ignore_patterns = ignore_files,
        layout_config = {
          width = 0.90,
          prompt_position = "top",
          preview_cutoff = 120,
          horizontal = { mirror = false },
          vertical = { mirror = false },
          preview_width = 0.55,
        },
        find_command = {
          "rg",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },
        prompt_prefix = " ",
        selection_caret = " ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        path_display = {},
        winblend = 0,
        border = {},
        borderchars = {
          "─",
          "│",
          "─",
          "│",
          "╭",
          "╮",
          "╯",
          "╰",
        },
        color_devicons = true,
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            -- ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            ["<C-q>"] = trouble.open_with_trouble,
            ["<esc>"] = actions.close,
            ["<CR>"] = actions.select_default + actions.center,
          },
          n = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            -- ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            ["<C-q>"] = trouble.open_with_trouble,
          },
        },
      },
    })
  end,
}
