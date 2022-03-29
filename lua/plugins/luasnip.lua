local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local fmt = require("luasnip.extras.fmt").fmt

-- basic configuration
ls.config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
})

-- snippets
-- TODO: this part will be moved to separate files for each filetype
ls.add_snippets("lua", { s("testing", { t("test!") }) })

ls.add_snippets("javascript", {
  -- cl: console.log({value}), basic thing
  s("cl", { t("console.log("), i(1), t(")") }),

  -- var: {const or let} {name}, variable declaration
  s(
    "var",
    fmt(
      [[
        {1} {2}
        ]],
      {
        c(1, { t("const"), t("let") }),
        i(2, "name"),
      }
    )
  ),

  -- ar: ({param}) => { () or {} }
  s(
    "ar",
    fmt(
      [[
        ({1}) => {2}
        ]],
      {
        i(1, "param"),
        c(2, {
          sn(nil, { t("("), i(1), t(")") }),
          sn(nil, { t("{"), i(1), t("}") }),
        }),
      }
    )
  ),
})

-- enable js, html snippets in jsx and tsx
-- the order matters here
ls.filetype_extend("javascriptreact", { "javascript", "html" })
ls.filetype_extend("typescript", { "javascript" })
ls.filetype_extend("typescriptreact", { "javascript", "typescript", "html" })

-- loading friendly snippets
-- require("luasnip/loaders/from_vscode").lazy_load({
--   paths = { "~/.config/nvim/friendly-snippets/" },
-- })

-- <c-k>: expansion key
-- this will expand the current item or jump to the next item within the snippet.
vim.keymap.set({ "i", "s" }, "<c-k>", function()
  if ls.jumpable(1) then
    ls.jump(1)
  elseif ls.expandable() then
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
