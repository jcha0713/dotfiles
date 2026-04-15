require("mini.visits").setup()

local visits = require("mini.visits")
local sort_recent = visits.gen_sort.default({ recency_weight = 1 })

vim.keymap.set("n", "ss", function()
  visits.select_path(nil, { sort = sort_recent })
end, { desc = "Select recent visited path" })

vim.keymap.set("n", "]s", function()
  visits.iterate_paths(
    "forward",
    vim.fn.getcwd(),
    { sort = sort_recent, wrap = true }
  )
end, { desc = "Next recent visited path" })

vim.keymap.set("n", "[s", function()
  visits.iterate_paths(
    "backward",
    vim.fn.getcwd(),
    { sort = sort_recent, wrap = true }
  )
end, { desc = "Previous recent visited path" })
