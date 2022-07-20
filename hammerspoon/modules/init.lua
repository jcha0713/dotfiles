local M

local modules = {
  "korToEng",
}

for _, module in ipairs(modules) do
  local modulePath = "modules." .. module
  require(modulePath)
end

return M
