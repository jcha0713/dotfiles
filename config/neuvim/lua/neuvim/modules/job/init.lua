local M = {}

function M.run(args, opts)
  local result = vim.system(args, opts or { text = true }):wait()
  if result.code ~= 0 then
    return nil, vim.trim(result.stderr or result.stdout or "command failed")
  end
  return result.stdout or ""
end

return M
