local M = {}

local autocmds = {
  "last_position",
  "yank_highlight",
  "no_auto_comment",
  "pack_hooks",
}

function M.setup()
  for _, autocmd in ipairs(autocmds) do
    require("neuvim.modules.autocmds." .. autocmd).init()
  end
end

return M
