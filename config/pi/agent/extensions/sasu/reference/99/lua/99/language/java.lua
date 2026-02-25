local M = {}

M.names = {}

--- @param item_name string
--- @return string
function M.log_item(item_name)
  return string.format("System.out.println(%s)", item_name)
end

return M
