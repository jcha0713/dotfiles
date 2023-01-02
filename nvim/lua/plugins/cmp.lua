local cmp = require("cmp")
local lspkind = require("lspkind")
local compare = require("cmp.config.compare")
local kanagawa = require("kanagawa.colors").setup()

vim.api.nvim_set_hl(0, "CmpCursorLine", { bg = "#a390a2", fg = "#171717" })
vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = kanagawa.oniViolet })
vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = kanagawa.surimiOrange })

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered({
      winhighlight = "CursorLine:CmpCursorLine",
    }),
    documentation = cmp.config.window.bordered(),
  },
  view = {
    entries = { name = "custom", selection_order = "near_cursor" },
  },
  formatting = {
    format = lspkind.cmp_format({
      with_text = true,
      maxwidth = math.floor(vim.api.nvim_win_get_width(0) / 2),
      maxheight = math.floor(vim.api.nvim_win_get_height(0) / 3 * 2),
      menu = {
        nvim_lsp = "[LSP]",
        fuzzy_buffer = "[Buf]",
        ["cmp-tw2css"] = "[TailwindCSS]",
        luasnip = "[Snip]",
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
    priority_weight = 100,
    comparators = {
      compare.locality,
      compare.recently_used,
      compare.score,
      compare.exact,
      compare.kind,
      -- require("cmp_fuzzy_buffer.compare"),
      -- compare.offset,
      -- compare.sort_text,
      -- compare.length,
      -- compare.order,
    },
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "cmp-tw2css" },
    {
      name = "fuzzy_buffer",
      keyword_length = 3,
      max_item_count = 10,
    },
    { name = "path" },
    { name = "neorg" },
    {
      name = "luasnip",
    },
    {
      name = "look",
      keyword_length = 5,
      max_item_count = 4,
      option = {
        convert_case = true,
        loud = true,
      },
    },
    { name = "crates" },
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
