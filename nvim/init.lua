vim.g.ts_highlight_lua = true

local imp_ok, _ = pcall(require, "impatient")
if not imp_ok then
  return
end

--General settings
require("plugins")
require("modules.keymappings")
require("modules.options")
require("modules.utils")
require("modules.autocmd")
require("modules.globals")
require("themes")
