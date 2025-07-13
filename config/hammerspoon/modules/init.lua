local M = {}

local modules = {
  "hyper",
  "korToEng",
}

-- load custom modules
function M.init()
  print("initializing modules ... ")
  for _, module in ipairs(modules) do
    local modulePath = "modules." .. module
    require(modulePath).init()
  end
end

return M
