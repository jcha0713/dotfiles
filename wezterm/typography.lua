local wezterm = require("wezterm")

local M = {}

local font_rules = {
  {
    italic = true,
    intensity = "Normal",
    font = wezterm.font_with_fallback({
      {
        family = "Monaspace Radon",
        style = "Italic",
      },
      {
        family = "hesalche",
      },
    }),
  },
}

M.set_fonts = function(config)
  config.font_size = 18.4
  config.line_height = 1.20
  config.font = wezterm.font_with_fallback({
    -- HACK: Adding flog symbols changes the entire look for some reason. Let's scale up a bit to mimic the original look.
    { family = "Flog Symbols", scale = 1.003 },
    "ComicCode Nerd Font",
    "hesalche",
    "PlemolJP Console NF",
  })
  config.font_rules = font_rules
end

return M
