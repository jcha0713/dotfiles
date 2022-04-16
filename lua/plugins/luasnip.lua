local ls = require("luasnip")
-- basic configuration
ls.config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
})

-- enable js, html snippets in jsx and tsx
-- the order matters here
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

-- <c-l>: selecting within a list of options.
-- This is useful for choice nodes (introduced in the forthcoming episode 2)
vim.keymap.set("i", "<c-l>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)

vim.keymap.set("i", "<c-u>", require("luasnip.extras.select_choice"))

-- shorcut to source my luasnips file again, which will reload my snippets
vim.keymap.set(
  "n",
  "<leader><leader>s",
  "<cmd>source ~/.config/nvim/lua/plugins/luasnip.lua<CR>"
)
