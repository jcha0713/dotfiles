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
  s("q", { t("Q: ") }),
  s("a", { t("A: ") }),
  s(
    "project",
    fmt(
      [[
        status: {}
        due: {}
        kind: {}
        ]],
      {
        c(1, {
          t("todo"),
          t("in progress"),
          t("done"),
        }),
        i(2, ""),
        c(3, {
          t("bug"),
          t("cicd"),
          t("documentation"),
          t("feature"),
          t("maintenance"),
          t("style"),
        }),
      }
    )
  ),
}
