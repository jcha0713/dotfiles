local M = {}

local autocmds = {
  "last_position",
  "lsp_progress",
  "yank_highlight",
  "no_auto_comment",
}

function M.setup()
  for _, autocmd in ipairs(autocmds) do
    require("neuvim.modules.autocmds." .. autocmd).init()
  end
end

return M
