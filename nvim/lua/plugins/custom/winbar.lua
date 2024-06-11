local M = {}

M.winbar_filetype = {
  "astro",
  "css",
  "gleam",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "lua",
  "markdown",
  "pug",
  "rust",
  "typescript",
  "typescriptreact",
}

M.get_winbar = function()
  if not vim.tbl_contains(M.winbar_filetype, vim.bo.filetype) then
    vim.opt_local.winbar = nil
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
