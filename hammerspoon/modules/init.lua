local M = {}

local modules = {
  "hyper",
  "korToEng",
  "wifiWatcher",
  "windowManager",
}

-- load custom modules
function M.init()
  for _, module in ipairs(modules) do
    local modulePath = "modules." .. module
    require(modulePath):init()
  end
end

return M
