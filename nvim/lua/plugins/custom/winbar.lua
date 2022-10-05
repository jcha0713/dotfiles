local M = {}

M.winbar_filetype = {
  "javascript",
  "typescript",
  "javascriptreact",
  "typescriptreact",
  "astro",
  "lua",
  "json",
  "html",
  "css",
  "markdown",
  "pug",
  "rust",
}

local includes = function()
  if vim.tbl_contains(M.winbar_filetype, vim.bo.filetype) then
    return false
  end
  vim.opt_local.winbar = nil
  return true
end

M.get_winbar = function()
  if includes() then
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
