local Popup = require("nui.popup")
local NuiText = require("nui.text")
local NuiLine = require("nui.line")
local if_nil = require("modules.utils").if_nil
local to_macos_keys = require("modules.utils").to_macos_keys

local Component = Popup:extend("Component")

function Component:mergeOptions(userOptions)
  local default_options = self:getDefaultOptions()
  return vim.tbl_deep_extend("force", default_options, if_nil(userOptions, {}))
end

function Component:getDefaultOptions()
  vim.api.nvim_set_hl(0, "NuiLabelSubmit", { fg = "#a390a2", bold = true })
  vim.api.nvim_set_hl(0, "NuiLabelCancel", { fg = "#ee90a2" })
  local top_label = NuiText(" Pop up ", "SpecialChar")
  local bottom_label = NuiLine()
  bottom_label:append(
    " (" .. to_macos_keys("D CR") .. ")" .. " Submit ",
    "NuiLabelSubmit"
  )
  bottom_label:append(" (esc)" .. " Cancel ", "NuiLabelCancel")

  return {
    enter = true,
    focusable = true,
    relative = "editor",
    border = {
      style = "rounded",
      padding = { 2, 4 },
      text = {
        top = top_label,
        top_align = "left",
        bottom = bottom_label,
        bottom_align = "right",
      },
    },
    position = "50%",
    size = { width = 60, height = 10 },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:SpecialChar",
    },
    zindex = 100,
  }
end

function Component:init(options, props)
  options = self:mergeOptions(options)

  props = if_nil(props, {})
  self.__props = props

  if self.__props.label then
    local paddedTopLabel = " " .. props.label.top .. " "
    options.border.text.top = paddedTopLabel
  end

  Component.super.init(self, options)
end

function Component:mount()
  Component.super.mount(self)

  self:__set_mapping()
  self:__set_default_text()
end

function Component:__set_mapping()
  local submit = "<D-CR>"

  if vim.fn.has("mac") ~= 1 then
    submit = "<C-CR>"
  end

  local default_mapping = {
    {
      mode = "n",
      from = "<C-c>",
      to = function()
        self:unmount()
      end,
    },
    {
      mode = "n",
      from = submit,
      to = function()
        self:submit()
      end,
    },
    {
      mode = "n",
      from = "<Esc>",
      to = function()
        self:abort()
      end,
    },
  }

  for _, mapping in pairs(default_mapping) do
    self:map(
      mapping.mode,
      mapping.from,
      mapping.to,
      { noremap = true, silent = true }
    )
  end
end

function Component:__set_default_text()
  local props = self:get_props()
  local default_text = if_nil(props.default_text, {})
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, default_text)
end

function Component:unmount()
  Component.super.unmount(self)

  vim.schedule(function()
    vim.api.nvim_command("stopinsert")
  end)
end

function Component:submit()
  local props = self:get_props()
  local on_submit = if_nil(props.on_submit, function()
    vim.notify("on_submit is not defined", vim.log.levels.WARN, {})
  end)
  local commit_msg_tbl = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
  local commit_msg = table.concat(commit_msg_tbl, "\n")
  on_submit(commit_msg)
  self:unmount()
end

function Component:abort()
  local props = self:get_props()
  local on_abort = if_nil(props.on_abort, function()
    vim.notify("on_abort is not defined", vim.log.levels.WARN, {})
  end)
  on_abort()
  self:unmount()
end

function Component:get_props()
  return self.__props
end

return Component
