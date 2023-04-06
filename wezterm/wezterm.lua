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
  font_size = 18.4,
  line_height = 1.20,
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
    {
      key = "t",
      mods = "LEADER",
      action = wezterm.action.ShowTabNavigator,
    },
    {
      key = "LeftArrow",
      mods = "LEADER",
      action = wezterm.action.SwitchWorkspaceRelative(-1),
    },
    {
      key = "RightArrow",
      mods = "LEADER",
      action = wezterm.action.SwitchWorkspaceRelative(1),
    },
    { key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    { key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
    {
      key = "n",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = wezterm.format({
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "Enter name for new workspace" },
        }),
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            local cwd = "~"
            if line == "knot" then
              cwd = "~/jhcha/dev/2023/project/knot"
            end
            if line == "blog" then
              cwd = "~/jhcha/dev/2021/project/jhcha-blog"
            end
            window:perform_action(
              act.SwitchToWorkspace({
                name = line,
                spawn = {
                  args = {
                    "zsh",
                    "-c",
                    "cd " .. cwd .. " && zsh",
                  },
                },
              }),
              pane
            )
          end
        end),
      }),
    },
    {
      key = "w",
      mods = "LEADER",
      action = act.ShowLauncherArgs({
        flags = "FUZZY|WORKSPACES",
      }),
    },
    { key = " ", mods = "LEADER", action = wezterm.action.QuickSelect },

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
