local M = {}

local modules = {
  "korToEng",
  "wifiWatcher",
}

-- load custom modules
function M.init()
  for _, module in ipairs(modules) do
    local modulePath = "modules." .. module
    require(modulePath):init()
  end
end

return M
