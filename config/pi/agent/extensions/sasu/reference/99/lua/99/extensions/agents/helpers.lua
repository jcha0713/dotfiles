local M = {}

--- @param path string
--- @return string
local function normalize_path(path)
  if path:sub(1, 1) == "/" then
    return path
  end
  if path:sub(1, 1) == "~" then
    return vim.fn.expand(path)
  end
  local cwd = vim.fs.joinpath(vim.uv.cwd(), path)
  return cwd
end

--- @param dir string
--- @return _99.Agents.Rule[]
function M.ls(dir)
  local current_dir = normalize_path(dir)
  local files = {}

  local direct_skill = vim.fs.joinpath(current_dir, "SKILL.md")
  if vim.fn.filereadable(direct_skill) == 1 then
    table.insert(files, direct_skill)
  else
    local glob = vim.fs.joinpath(current_dir, "*/SKILL.md")
    files = vim.fn.glob(glob, false, true)
  end
  local rules = {}

  local cwd = vim.uv.cwd()
  for _, file in ipairs(files) do
    local filename = vim.fn.fnamemodify(file, ":h:t")
    local relative_path = file
    if cwd and file:sub(1, #cwd) == cwd then
      relative_path = file:sub(#cwd + 2) -- +2 to skip the trailing slash
    end
    table.insert(rules, {
      name = filename,
      path = relative_path,
      absolute_path = file,
    })
  end

  return rules
end

--- @param file string
--- @param count? number
--- @return string
function M.head(file, count)
  count = count or 5
  local fd = vim.uv.fs_open(file, "r", 438)
  if not fd then
    return ""
  end

  local stat = vim.uv.fs_fstat(fd)
  if not stat then
    vim.uv.fs_close(fd)
    return ""
  end

  local data = vim.uv.fs_read(fd, stat.size, 0)
  vim.uv.fs_close(fd)

  if not data then
    return ""
  end

  local lines = {}
  for line in data:gmatch("([^\n]*)\n?") do
    if count == 0 then
      break
    end
    count = count - 1
    table.insert(lines, line)
  end

  return table.concat(lines, "\n")
end

return M
