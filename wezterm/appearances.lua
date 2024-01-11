local wezterm = require("wezterm")

local M = {}

M.set_display = function(config)
  config.check_for_updates = false
  config.color_scheme = "Arthur"
  config.enable_tab_bar = false
  config.force_reverse_video_cursor = true
  config.window_background_opacity = 1
  config.window_padding = {
    left = 4,
    right = 0,
    top = 0,
    bottom = 0,
  }
end

return M
