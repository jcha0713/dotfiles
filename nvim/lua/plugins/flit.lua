return {
  "ggandor/flit.nvim",
  event = "VeryLazy",
  config = function()
    require("flit").setup({
      keys = { f = "f", F = "F", t = "t", T = "T" },
      -- A string like "nv", "nvo", "o", etc.
      labeled_modes = "nvo",
      multiline = true,
      opts = {},
    })
  end,
}
