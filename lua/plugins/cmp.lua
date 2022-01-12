local cmp = require "cmp"

local lspkind = require "lspkind"
local ls = require "luasnip"

cmp.setup {
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  formatting = {
    format = lspkind.cmp_format {
      with_text = true,
      maxwidth = math.floor(vim.api.nvim_win_get_width(0) / 2),
      maxheight = math.floor(vim.api.nvim_win_get_height(0) / 3 * 2),
      menu = {
        buffer = "[Buf]",
        nvim_lsp = "[LSP]",
        luasnip = "[Snip]",
        nvim_lua = "[Lua]",
        cmp_tabnine = "[TN]",
        look = "[Dict]",
      },
    },
  },
  mapping = {
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-u>"] = cmp.mapping.scroll_docs(4),
    -- ["<C-space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm(),
    --[[ ["<C-f>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }, ]]
    ["<tab>"] = cmp.mapping(function(fallback)
      if ls.expand_or_jumpable() then
        ls.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<s-tab>"] = cmp.mapping(function(fallback)
      if ls.jumpable(-1) then
        ls.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = "luasnip" },
    { name = "nvim_lua" },
    { name = "nvim_lsp" },
    { name = "cmp_tabnine" },
    { name = "path" },
    {
      name = "fuzzy_buffer",
      keyword_length = 5,
      max_item_count = 10,
    },
    { name = "neorg" },
    {
      name = "look",
      keyword_length = 2,
      max_item_count = 4,
      option = {
        convert_case = true,
        loud = true,
      },
    },
    { name = "orgmode" },
  },
  experimental = {
    native_menu = false,
    ghost_text = false,
  },
}

-- pmenu style
local Color, colors, Group, groups = require("colorbuddy").setup()
Color.new("pMatch", "#92b7d7")

Group.new("CmpMatch", colors.pMatch, nil)
Group.new("CmpItemAbbrMatch", groups.CmpMatch, nil)
