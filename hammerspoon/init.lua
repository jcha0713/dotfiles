local secret = require("secret")
secret.init(".secret.json")

-- initialize modules
--
local modules = require("modules")
modules.init()

local hyper = require("modules.hyper")

hyper.bind({}, "r", nil, function()
  hs.reload()
end)

-- Spoons

-- annotations
-- hs.loadSpoon("EmmyLua")

-- Config Reloading
hs.notify.new({ title = "Hammerspoon", informativeText = "Config loaded" }):send()
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
