require("cursortab").setup({
  provider = {
    type = "mercuryapi",
    api_key_env = "INCEPTION_KEY",
  },
  behavior = {
    disabled_in = {
      "comment",
      "string",
    },
    ignore_filetypes = {
      "markdown",
      "txt",
    },
  },
})
