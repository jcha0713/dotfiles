local M = {}
--- TODO: some people change their current working directory as they open new
--- directories.  if this is still the case in neovim land, then we will need
--- to make the _99_state have the project directory.
--- @return string
function M.random_file()
  return string.format(
    "%s/tmp/99-%d",
    vim.uv.cwd(),
    math.floor(math.random() * 10000)
  )
end

return M
