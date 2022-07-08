local M = {}

M.winbar_filetype_exclude = {
  "help",
  "startify",
  "packer",
  "neogitstatus",
  "neo-tree",
  "Trouble",
  "NvimTree",
  "toggleterm",
}

local excludes = function()
  if vim.tbl_contains(M.winbar_filetype_exclude, vim.bo.filetype) then
    vim.opt_local.winbar = nil
    return true
  end
  return false
end

M.get_winbar = function()
  if excludes() then
    return
  end

  local function get_value()
    local right_align = "%="
    local modified = " %-m"
    local file_name = "%f"

    return string.format("%s%s %s", right_align, modified, file_name)
  end

  local status_ok, _ = pcall(
    vim.api.nvim_set_option_value,
    "winbar",
    get_value(),
    { scope = "local" }
  )
  if not status_ok then
    return
  end
end

return M
