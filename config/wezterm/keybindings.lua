local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

M.set_keys = function(config)
  config.leader = { key = "a", mods = "CMD", timeout_milliseconds = 1000 }

  config.keys = {
    {
      key = "f",
      mods = "CMD",
      action = act.ToggleFullScreen,
    },
    {
      key = "p",
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

    -- toggle pane zoom state
    {
      key = "z",
      mods = "LEADER",
      action = wezterm.action.TogglePaneZoomState,
    },

    -- window movement:
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

    -- close pane
    {
      key = "d",
      mods = "LEADER",
      action = act.CloseCurrentPane({ confirm = false }),
    },
    -- cmd+o: gt(next tab)
    -- cmd+i: gT(prev tab)
    {
      key = "i",
      mods = "CMD",
      action = act.Multiple({
        act.SendKey({ key = "g" }),
        act.SendKey({ key = "t" }),
      }),
    },
    {
      key = "o",
      mods = "CMD",
      action = act.Multiple({
        act.SendKey({ key = "g" }),
        act.SendKey({ key = "T" }),
      }),
    },
  }
end

return M
