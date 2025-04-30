-- local ignore_files = {
--   "node_modules/.*",
--   -- ".git/.*",
--   ".yarn/.*",
--   ".neuron/*",
--   "fonts/*",
--   -- "icons/*",
--   "images/*",
--   "dist/*",
--   "build/*",
--   "yarn.lock",
--   "package%-lock.json",
--   "lazy%-lock.json",
--   "%.svg",
--   -- "%.png",
--   -- "%.jpeg",
--   -- "%.jpg",
--   -- "%.webp",
--   "%.ico",
--   "data/lua%-language%-server",
--   ".DS_Store",
--   "/EmmyLua.spoon/annotations/*",
-- }

local picker_opt = {
  defaults = {
    file_ignore_patterns = {},
  },
  registers = {
    theme = "cursor",
  },
  live_grep = {
    theme = "ivy",
  },
  lsp_references = {
    theme = "cursor",
  },
  lsp_definitions = {
    theme = "cursor",
  },
  lsp_document_symbols = {
    theme = "cursor",
  },
}

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- "folke/trouble.nvim",
    "BurntSushi/ripgrep",
    "nvim-lua/popup.nvim",
    "nvim-telescope/telescope-media-files.nvim",
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
    {
      "<leader>gs",
      ":Telescope grep_string<CR>",
      desc = "Telescope grep string",
    },
    {
      "<leader>fh",
      ":Telescope help_tags<CR>",
      desc = "Telescope find help",
    },
    { "<leader>bf", ":Telescope buffers<CR>", desc = "Telescope buffers" },
    {
      "<leader>of",
      ":Telescope oldfiles<CR>",
      desc = "Telescope old files",
    },
    { "<leader>cm", ":Telescope commands<CR>", desc = "Telescope commands" },
    { "<leader>km", ":Telescope keymaps<CR>", desc = "Telescope keymaps" },
    {
      "<leader>rg",
      ":Telescope registers<CR>",
      desc = "Telescope registers",
    },
    {
      "<leader>lr",
      ":Telescope lsp_references<CR>",
      desc = "Telescope lsp references",
    },
    {
      "<leader>sm",
      ":Telescope lsp_document_symbols<CR>",
      desc = "Telescope document symbols",
    },
  },
  config = function()
    local actions = require("telescope.actions")
    -- local trouble = require("trouble.providers.telescope")

    require("telescope").setup({
      pickers = picker_opt,
      defaults = {
        file_ignore_patterns = ignore_files,
        preview = { -- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#use-terminal-image-viewer-to-preview-images
          treesitter = true,
          mime_hook = function(filepath, bufnr, opts)
            local is_image = function(filepath)
              local image_extensions = { "png", "jpg" } -- Supported image formats
              local split_path =
                vim.split(filepath:lower(), ".", { plain = true })
              local extension = split_path[#split_path]
              return vim.tbl_contains(image_extensions, extension)
            end
            if is_image(filepath) then
              local term = vim.api.nvim_open_term(bufnr, {})
              local function send_output(_, data, _)
                for _, d in ipairs(data) do
                  vim.api.nvim_chan_send(term, d .. "\r\n")
                end
              end
              vim.fn.jobstart({
                "catimg",
                filepath, -- Terminal image viewer command
              }, {
                on_stdout = send_output,
                stdout_buffered = true,
                pty = true,
              })
            else
              require("telescope.previewers.utils").set_preview_message(
                bufnr,
                opts.winid,
                "Binary cannot be previewed"
              )
            end
          end,
        },
        layout_config = {
          width = 0.90,
          prompt_position = "top",
          preview_cutoff = 120,
          horizontal = { mirror = false, preview_width = 0.55 },
          vertical = { mirror = false },
          -- preview_width = 0.55,
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
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
        mappings = {
          i = {
            -- ["<C-p>"] = actions.move_selection_next,
            -- ["<C-n>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            -- ["<C-q>"] = trouble.open_with_trouble,
            ["<esc>"] = actions.close,
            ["<CR>"] = actions.select_default + actions.center,
          },
          n = {
            -- ["<C-p>"] = actions.move_selection_next,
            -- ["<C-n>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            -- ["<C-q>"] = trouble.open_with_trouble,
          },
        },
      },
    })

    require("telescope").load_extension("media_files")
    require("telescope").load_extension("smart_open")
  end,
}
