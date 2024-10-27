local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s(
    "pipe",
    fmt(
      [[
      {1} |> {2}
    ]],
      {
        i(1, ""),
        i(2, ""),
      }
    )
  ),
  s(
    "use",
    fmt(
      [[
      use {1} <- {2}({3})
    ]],
      {
        i(1, "val"),
        i(2, "f"),
        i(3, "params"),
      }
    )
  ),
}
