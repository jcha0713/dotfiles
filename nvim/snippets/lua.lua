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
  s("req", { t("require("), i(0, "module"), t(")") }),
  s(
    "lreq",
    { t("local "), i(1, "name"), t(" = require("), i(0, "module"), t(")") }
  ),
  s(
    "use",
    fmt(
      [[
      use({{
        "{1}",
        config = function()
          require("plugins.{2}")
        end,
      }})
      ]],
      {
        i(1),
        f(function(plugin_name)
          local splits = vim.split(
            plugin_name[1][1],
            "/",
            { plain = true, trimempty = true }
          )
          if splits[#splits] ~= nil then
            return splits[#splits]:gsub(".nvim", "")
          end
          return ""
        end, { 1 }),
      }
    )
  ),
}
