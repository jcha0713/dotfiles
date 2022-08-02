local M = {}

local hyper = hs.hotkey.modal.new({}, nil)

hyper.pressed = function()
  hyper:enter()
end

hyper.released = function()
  hyper:exit()
end

M.bind = function(mod, key, message, callbackFn)
  hyper:bind(mod, key, message, callbackFn)
end

function M.init()
  -- Set the F19 HYPER
  -- Bind the Hyper key to the hammerspoon modal
  hs.hotkey.bind({}, "F19", hyper.pressed, hyper.released)
end

return M
