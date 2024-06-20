return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.setup({
      plugins = {
        presets = {
          operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
          motions = false, -- adds help for motions
          text_objects = true, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling and others prefixed with z
          g = true, -- bindings for prefixed with g
        },
        spelling = {
          enabled = true,
          suggestions = 8,
        },
      },
      window = {
        border = "single",
      },
    })

    wk.register({
      ["<leader>"] = {
        z = {
          name = "+zettlekasten",
        },
      },

      ["]"] = { name = "+next" },
      ["["] = { name = "+prev" },
    })
  end,
}
