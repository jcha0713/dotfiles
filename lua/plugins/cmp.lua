local cmp = require "cmp"

local lspkind = require "lspkind"

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
      },
    },
  },
  mapping = {
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-u>"] = cmp.mapping.scroll_docs(4),
    ["<C-space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm(),
    --[[ ["<C-f>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }, ]]
    --   ["<tab>"] = function(fallback)
    --     if
    --     else
    --       fallback()
    --     end
    --   end,
    --   ["<s-tab>"] = function(fallback)
    --     if
    --     else
    --       fallback()
    --     end
    --   end,
  },
  sources = {
    { name = "nvim_lua" },
    { name = "nvim_lsp" },
    { name = "cmp_tabnine" },
    { name = "path" },
    { name = "luasnip" },
    {
      name = "fuzzy_buffer",
      keyword_length = 5,
      max_item_count = 10,
    },
  },
  experimental = {
    native_menu = false,
    ghost_text = false,
  },
}
