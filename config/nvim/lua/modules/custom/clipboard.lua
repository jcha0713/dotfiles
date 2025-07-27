local M = {}

local function set_osc52_clipboard()
  local function paste()
    return {
      vim.split(vim.fn.getreg(""), "\n"),
      vim.fn.getregtype(""),
    }
  end

  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }
end

local function check_wezterm_remote_clipboard(callback)
  local wezterm_executable = vim.uv.os_getenv("WEZTERM_EXECUTABLE")

  if
    wezterm_executable
    and wezterm_executable:find("wezterm-mux-server", 1, true)
  then
    callback(true)
  else
    callback(false)
  end
end

function M.setup()
  vim.schedule(function()
    vim.opt.clipboard:append("unnamedplus")

    if
      vim.uv.os_getenv("SSH_CLIENT") ~= nil
      or vim.uv.os_getenv("SSH_TTY") ~= nil
    then
      set_osc52_clipboard()
    else
      check_wezterm_remote_clipboard(function(is_remote_wezterm)
        if is_remote_wezterm then
          set_osc52_clipboard()
        end
      end)
    end
  end)
end

return M
