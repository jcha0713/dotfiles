local utils = require("modules.utils")
local actions = require("telescope.actions")
local trouble = require("trouble.providers.telescope")

local M = {}

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
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
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
    extensions = {
      file_browser = {},
      bookmarks = {
        selected_browser = "brave",

        -- Either provide a shell command to open the URL
        url_open_command = "open",

        -- Or provide the plugin name which is already installed
        -- Available: 'vim_external', 'open_browser'
        url_open_plugin = nil,

        -- Show the full path to the bookmark instead of just the bookmark name
        full_path = true,

        -- Provide debug messages
        debug = false,
      },
    },
  },
})

-- require("telescope").load_extension "projects"
require("telescope").load_extension("fzf")
require("telescope").load_extension("file_browser")
require("telescope").load_extension("bookmarks")

local builtin = function(mapping, picker, opts)
  opts = opts or {}
  -- local module = is_custom and "plugins.telescope" or "telescope.builtin"
  -- local rhs = string.format("<cmd>lua require'%s'.%s(opts)<cr>", module, picker)
  utils.map("n", mapping, function()
    require("telescope.builtin")[picker](opts)
  end)
end

local custom = function(mapping, picker_name, builtin_name, opts)
  opts = opts or {}
  M[picker_name] = function()
    require("telescope.builtin")[builtin_name](opts)
  end
  local rhs = string.format(
    [[<cmd>lua require'plugins.telescope'.%s()<cr>]],
    picker_name
  )
  utils.map("n", mapping, rhs)
end

builtin("<M-\\>", "builtin")
builtin("<Leader>ff", "find_files", { hidden = true })
builtin("<Leader>gr", "live_grep")
builtin("<Leader>bf", "buffers")
builtin("<Leader>gf", "git_files")
builtin("<Leader>jp", "jumplist")
builtin("<Leader>fh", "help_tags")
builtin("<Leader>of", "oldfiles")
builtin("<Leader>fb", "file_browser")
builtin("<Leader>cm", "commands")
builtin("<Leader>gs", "grep_string")
builtin("<Leader>km", "keymaps")
builtin("<Leader>bm", "bookmarks")

custom("<leader>nv", "find_nvim", "find_files", {
  cwd = "~/.config/nvim",
  prompt_title = "find files in neovim config",
})

custom("<leader>gnv", "grep_nvim", "live_grep", {
  cwd = "~/.config/nvim",
  prompt_title = "find files in neovim config",
})

custom("<leader>jh", "find_jhcha", "find_files", {
  cwd = "/Users/jcha0713/jhcha/dev/",
  prompt_title = "find files in my personal workspace",
})

custom("<leader>gjh", "grep_jhcha", "live_grep", {
  cwd = "/Users/jcha0713/jhcha/dev/",
  prompt_title = "grep in my personal workspace",
})

custom("<leader>nt", "find_note", "find_files", {
  cwd = "/Users/jcha0713/jhcha/note",
  prompt_title = "find files in my note folder",
})

custom("<leader>gnt", "grep_note", "live_grep", {
  cwd = "/Users/jcha0713/jhcha/note/",
  prompt_title = "grep in my note folder",
})

return M
