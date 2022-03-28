local cmp = require("cmp")

local lspkind = require("lspkind")
local ls = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  formatting = {
    format = lspkind.cmp_format({
      with_text = true,
      maxwidth = math.floor(vim.api.nvim_win_get_width(0) / 2),
      maxheight = math.floor(vim.api.nvim_win_get_height(0) / 3 * 2),
      menu = {
        buffer = "[Buf]",
        nvim_lsp = "[LSP]",
        luasnip = "[Snip]",
        nvim_lua = "[Nvim]",
        look = "[Dict]",
      },
    }),
  },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-u>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm(),
  },
  sources = cmp.config.sources({
    { name = "luasnip" },
    { name = "nvim_lua" },
    { name = "nvim_lsp" },
    { name = "path" },
    {
      name = "fuzzy_buffer",
      keyword_length = 5,
      max_item_count = 10,
    },
    { name = "neorg" },
    {
      name = "look",
      keyword_length = 5,
      max_item_count = 4,
      option = {
        convert_case = true,
        loud = true,
      },
    },
    { name = "orgmode" },
  }),
  experimental = {
    native_menu = false,
    ghost_text = false,
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})
