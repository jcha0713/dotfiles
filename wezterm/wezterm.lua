local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  -- window:gui_window():maximize()
  -- open wezterm in fullscreen mode
  window:gui_window():toggle_fullscreen()
end)

wezterm.on("update-right-status", function(window, pane)
  window:set_right_status(window:active_workspace())
end)

return {
  color_scheme = "kanagawa-dark",
  enable_tab_bar = false,
  force_reverse_video_cursor = true,
  window_background_opacity = 1,
  window_padding = {
    left = 4,
    right = 4,
    top = 0,
    bottom = 0,
  },
  font_size = 18.2,
  line_height = 1.32,
  font = wezterm.font("ComicCode Nerd Font"),
  leader = { key = "a", mods = "CMD", timeout_milliseconds = 1000 },
  keys = {
    {
      key = "f",
      mods = "CMD",
      action = act.ToggleFullScreen,
    },
    {
      key = "l",
      mods = "LEADER",
      action = wezterm.action.ShowLauncher,
    },

    -- split pane:
    {
      key = "|",
      mods = "LEADER",
      action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    {
      key = "_",
      mods = "LEADER",
      action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
    },

    -- window movement:
    { key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },

    -- close pane
    {
      key = "d",
      mods = "LEADER",
      action = act.CloseCurrentPane({ confirm = false }),
    },
  },
}
