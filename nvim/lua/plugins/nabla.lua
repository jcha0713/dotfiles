local nabla = require("nabla")
local utils = require("modules.utils")
local map = utils.map

map("n", "<leader>ma", function()
  nabla.enable_virt()
end)
