local cmp = require("cmp")
local compare = require("cmp.config.compare")
local lspkind = require("lspkind")

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
        nvim_lsp = "[LSP]",
        luasnip = "[Snip]",
        nvim_lua = "[Nvim]",
        fuzzy_buffer = "[Buf]",
        look = "[Dict]",
      },
    }),
  },
  mapping = {
    ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
    ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-s>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm(),
  },
  -- experimental = {
  --   ghost_text = { hl_group = "CmpItemAbbrMatch" },
  -- },
  sorting = {
    priority_weight = 2,
    comparators = {
      require("cmp_fuzzy_buffer.compare"),
      compare.offset,
      compare.exact,
      compare.score,
      compare.recently_used,
      compare.kind,
      compare.sort_text,
      compare.length,
      compare.order,
    },
  },
  sources = cmp.config.sources({
    { name = "cmp-tw2css" },
    { name = "nvim_lsp" },
    {
      name = "luasnip",
    },
    { name = "nvim_lua" },
    {
      name = "fuzzy_buffer",
      keyword_length = 5,
      max_item_count = 10,
    },
    { name = "path" },
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
  }),
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})
