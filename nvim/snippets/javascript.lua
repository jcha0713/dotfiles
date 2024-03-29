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

return {

  -- cl: console.log({value}), basic thing
  s("cl", { t("console.log("), i(1), t(")") }),

  -- v: {const or let} {name}, variable declaration
  s(
    "v",
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
        i(1),
        c(2, {
          sn(nil, { t("("), i(1), t(")") }),
          sn(nil, { t("{"), i(1), t("}") }),
        }),
      }
    )
  ),

  -- imp: import statement
  s(
    "imp",
    fmt(
      [[
      import {2} from '{1}'
      ]],
      {
        i(1),
        c(2, {
          sn(nil, { t("{"), i(1), t("}") }),
          sn(nil, { i(1) }),
        }),
      }
    )
  ),

  -- etw: easy-tailwind
  s("etw", { t("import { e } from 'easy-tailwind'") }),
}
