local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

function M.test()
  local item = ts_utils.get_node_at_cursor(0)

  if not item then
    return
  end

  while item:type() ~= "todo_item1" do
    if item:parent() == nil then
      return
    end

    item = item:parent()
  end

  local item_str = vim.treesitter.query.get_node_text(item, 0)

  local item_tbl = {}
  for line in string.gmatch(item_str, "([^\n]*)\n?") do
    table.insert(item_tbl, line)
  end

  if item:parent() ~= nil and item:parent():type() == "generic_list" then
    if
      item:parent():parent() ~= nil
      and item:parent():parent():type() == "carryover_tag_set"
    then
      item = item:parent():parent()
    end
  end

  local start_row, _, end_row, _ = item:range()
  vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, {})
  vim.api.nvim_command("Neorg journal today")
  -- local config =
  --   require("neorg.modules.core.norg.journal.module").real().config.public
  -- P(config)
  vim.fn.writefile(item_tbl, vim.fn.expand("%"), "a")
  vim.cmd("edit")
end

M.test()

return M
