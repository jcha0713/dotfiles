local M = {}

local function paste()
  return {
    vim.split(vim.fn.getreg(""), "\n"),
    vim.fn.getregtype(""),
  }
end

function M.setup()
  if vim.env.SSH_TTY then
    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
      },
      paste = {
        ["+"] = paste,
        ["*"] = paste,
      },
    }
  end
end

return M
