local secret = require("secret")
secret.init(".secret.json")

require("modules")

-- hs.loadSpoon("EmmyLua")
-- CONFIG RELOADING:
hs.notify.new({ title = "Hammerspoon", informativeText = "Config loaded" }):send()
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
