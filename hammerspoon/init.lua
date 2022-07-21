require("modules")

-- hs.loadSpoon("EmmyLua")
--
-- CONFIG RELOADING:
hs.notify.new({ title = "Hammerspoon", informativeText = "Config loaded" }):send()
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

local window_movement = function(bind_key, direction)
  hs.hotkey.bind({ "cmd", "shift" }, bind_key, function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    local options = {
      left = {
        x = max.x,
        y = max.y,
        w = max.w / 2,
        h = max.h,
      },
      right = {
        x = max.x + (max.w / 2),
        y = max.y,
        w = max.w / 2,
        h = max.h,
      },
      up = {
        x = max.x,
        y = max.y,
        w = max.w,
        h = max.h / 2,
      },
      down = {
        x = max.x,
        y = max.y + (max.h / 2),
        w = max.w,
        h = max.h / 2,
      },
      full = {
        x = max.x,
        y = max.y,
        w = max.w,
        h = max.h,
      },
    }

    f.x = options[direction].x
    f.y = options[direction].y
    f.w = options[direction].w
    f.h = options[direction].h

    win:setFrame(f)
  end)
end

window_movement("Left", "left")
window_movement("Right", "right")
window_movement("Up", "up")
window_movement("Down", "down")
window_movement("Space", "full")
