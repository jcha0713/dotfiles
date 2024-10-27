return {
  "jackMort/ChatGPT.nvim",
  enabled = false,
  event = "VeryLazy",
  config = function()
    require("chatgpt").setup({
      api_key_cmd = "op read op://private/OPENAI-API-KEY/key --no-newline",
      edit_with_instructions = {
        diff = false,
      },
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim",
  },
}
