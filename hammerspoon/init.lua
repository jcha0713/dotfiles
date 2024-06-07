-- initialize modules

local modules = require("modules")
modules.init()

local hyper = require("modules.hyper")

hyper.bind({}, "r", nil, function()
  hs.reload()
end)
hyper.bind({ "shift" }, "m", nil, function()
  hs.application.launchOrFocus("Messages")
end)

hyper.bind({ "shift" }, "d", nil, function()
  hs.application.launchOrFocus("Discord")
end)

local secret = require("secret")
secret.init(".secret.json")

-- Spoons

-- annotations
-- hs.loadSpoon("EmmyLua")

-- Config Reloading
hs.notify
  .new({ title = "Hammerspoon", informativeText = "Config loaded" })
  :send()
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
