return {
  "L3MON4D3/Luasnip",
  event = "InsertEnter",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  config = function()
    local ls = require("luasnip")
    local session = require("luasnip.session")

    local Menu = require("nui.menu")
    local event = require("nui.utils.autocmd").event

    -- basic configuration
    ls.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
    })

    -- enable js, html snippets in jsx and tsx
    -- the order matters here
    ls.filetype_extend("astro", { "javascript" })
    ls.filetype_extend("javascriptreact", { "javascript", "html" })
    ls.filetype_extend("typescript", { "javascript" })
    ls.filetype_extend(
      "typescriptreact",
      { "javascript", "typescript", "html" }
    )

    -- load snippets from ~/.config/nvim/snippets directory
    require("luasnip.loaders.from_lua").load({
      paths = "~/.config/nvim/snippets",
    })

    -- loading friendly snippets
    -- require("luasnip/loaders/from_vscode").lazy_load({
    --   paths = { "~/.config/nvim/friendly-snippets/" },
    -- })

    -- <c-k>: jump forward key
    -- this will jump to the next item within the snippet.
    vim.keymap.set({ "i", "s" }, "<c-k>", function()
      if ls.jumpable(1) then
        ls.jump(1)
      end
    end, { silent = true })

    -- <c-f>: expand key (go 'f'orward into snippet)
    -- this expands the snippet
    vim.keymap.set({ "i", "s" }, "<c-f>", function()
      if ls.expandable() then
        ls.expand()
      end
    end, { silent = true })

    -- <c-j>: jump backwards key.
    -- this always moves to the previous item within the snippet
    vim.keymap.set({ "i", "s" }, "<c-j>", function()
      if ls.jumpable(-1) then
        ls.jump(-1)
      end
    end, { silent = true })

    -- <c-l>: cycling up the list of choice nodes
    -- vim.keymap.set({ "i", "v" }, "<c-l>", function()
    --   if ls.choice_active() then
    --     require("luasnip.extras.select_choice")()
    --   end
    -- end)

    local function get_menu_choices()
      local menu_choices = {}

      for i, choice in ipairs(session.active_choice_node.choices) do
        local item = choice:get_docstring()[1]
        table.insert(menu_choices, Menu.item(item, { id = i }))
      end

      return menu_choices
    end

    -- <c-l>: selecting within a list of options.
    -- this uses nui.nvim for ui
    vim.keymap.set({ "i", "v" }, "<c-l>", function()
      vim.cmd("stopi")
      if ls.choice_active() then
        local menu = Menu({
          relative = "cursor",
          position = {
            row = 2,
            col = 1,
          },
          size = {
            width = 30,
          },
          border = {
            style = "rounded",
            text = {
              top = "[Choose Item]",
              top_align = "center",
            },
          },
          win_options = {
            winhighlight = "Normal:Normal",
          },
        }, {
          lines = get_menu_choices(),
          prepare_item = function(item)
            item = string.gsub(item.text, "${(.*)}", "%1", 1)
            if string.len(item) == 0 then
              item = "empty"
            end
            return item
          end,
          keymap = {
            focus_next = { "j", "<Down>", "<Tab>" },
            focus_prev = { "k", "<Up>", "<S-Tab>" },
            close = { "<Esc>", "<C-c>" },
            submit = { "<CR>", "<Space>" },
          },
          on_clonse = nil,
          on_submit = function(item)
            ls.set_choice(item:get_id())
          end,
        })

        menu:mount()

        menu:on({ event.BufLeave }, function()
          menu:unmount()
        end, { once = true })
      end
    end)

    -- shorcut to source my luasnips file again, which will reload my snippets
    vim.keymap.set(
      "n",
      "<leader><leader>s",
      "<cmd>source ~/.config/nvim/lua/plugins/luasnip.lua<CR>"
    )
  end,
}
