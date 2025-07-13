local M = {}

M.bind = function(mod, key, fn)
  hs.hotkey.bind(mod, key, fn)
end

return M
