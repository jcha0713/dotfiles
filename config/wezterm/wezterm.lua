local wezterm = require("wezterm")
local mux = wezterm.mux
local display = require("appearances")
local fonts = require("typography")
local keys = require("keybindings")
local settings = require("settings")

local config = {}

wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  local daily_pane = pane:split({
    size = 0.1,
  })
  daily_pane:send_text("env NVIM_MODE=zk zk daily\n")
end)

wezterm.on("update-right-status", function(window, pane)
  window:set_right_status(window:active_workspace())
end)

if wezterm.config_builder then
  config = wezterm.config_builder()
end

display.set_display(config)
fonts.set_fonts(config)
keys.set_keys(config)
settings.set_settings(config)

return config
