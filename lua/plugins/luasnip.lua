local ls = require "luasnip"

ls.config.set_config {
  history = true,
  updateevents = "TextChanged,TextChangedI",
}

ls.snippets = {
  html = {},
}

-- enable html snippets in javascript/javascript(REACT)
ls.snippets.javascript = ls.snippets.html
ls.snippets.typescript = ls.snippets.html
ls.snippets.javascriptreact = ls.snippets.html
ls.snippets.typescriptreact = ls.snippets.html
require("luasnip/loaders/from_vscode").lazy_load {
  paths = { "~/.local/share/nvim/site/pack/packer/start/friendly-snippets" },
}
