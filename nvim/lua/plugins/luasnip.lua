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
ls.filetype_extend("typescriptreact", { "javascript", "typescript", "html" })

-- load snippets from ~/.config/nvim/snippets directory
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })

-- loading friendly snippets
require("luasnip/loaders/from_vscode").lazy_load({
  paths = { "~/.config/nvim/friendly-snippets/" },
})

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

-- <c-u>: cycling up the list of choice nodes
vim.keymap.set("i", "<c-u>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)

local function no_region_check_wrap(fn, ...)
  session.jump_active = true
  -- will run on next tick, after autocommands (especially CursorMoved) for this are done.
  vim.schedule(function()
    session.jump_active = false
  end)
  return fn(...)
end

local function set_choice_callback(_, indx)
  local choice = indx and session.active_choice_node.choices[indx]
  if not choice then
    return
  end
  local new_active = no_region_check_wrap(
    session.active_choice_node.set_choice,
    session.active_choice_node,
    choice,
    session.current_nodes[vim.api.nvim_get_current_buf()]
  )
  session.current_nodes[vim.api.nvim_get_current_buf()] = new_active
end

local function get_menu_choices()
  local menu_choices = {}

  for i, choice in ipairs(session.active_choice_node.choices) do
    table.insert(menu_choices, Menu.item(choice:get_docstring()[1], { id = i }))
  end

  return menu_choices
end

-- <c-l>: selecting within a list of options.
-- this uses nui.nvim for ui
vim.keymap.set("i", "<c-l>", function()
  if ls.choice_active() then
    assert(session.active_choice_node, "No active choiceNode")

    local menu = Menu({
      relative = "cursor",
      position = {
        row = 1,
        col = 0,
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
      prepare_item = function(item)
        print(item.text)
        return string.gsub(item.text, "${(.*)}", "%1", 1)
      end,
      lines = get_menu_choices(),
      keymap = {
        focus_next = { "j", "<Down>", "<Tab>" },
        focus_prev = { "k", "<Up>", "<S-Tab>" },
        close = { "<Esc>", "<C-c>" },
        submit = { "<CR>", "<Space>" },
      },
      on_close = function()
        print("Menu Closed!")
      end,
      on_submit = function(item)
        set_choice_callback(_, item:get_id())
      end,
    })

    if vim.fn.mode() ~= "n" then
      vim.api.nvim_input("<Esc>")
    end

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
