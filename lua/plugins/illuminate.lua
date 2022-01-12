local u = require "modules.utils"

u.map(
  "n",
  "<A-n>",
  '<cmd> lua require"illuminate".next_reference{wrap=true}<CR>'
)
u.map(
  "n",
  "<A-p>",
  '<cmd> lua require"illuminate".next_reference{reverse=true,wrap=true}<CR>'
)
