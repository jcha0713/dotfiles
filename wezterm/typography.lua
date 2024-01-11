local wezterm = require("wezterm")

local M = {}

M.set_fonts = function(config)
  config.font_size = 18.4
  config.line_height = 1.20
  config.font = wezterm.font_with_fallback({
    "ComicCode Nerd Font",
    "hesalche",
  })
end

return M
