return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "saadparwaiz1/cmp_luasnip",
    "tamago324/nlsp-settings.nvim",
    "onsails/lspkind-nvim",
    "octaltree/cmp-look",
    "jcha0713/cmp-tw2css",
  },
  config = function()
    local cmp = require("cmp")
    local lspkind = require("lspkind")
    local compare = require("cmp.config.compare")

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
        ["<CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        }),
      },
      sorting = {
        priority_weight = 2,
        comparators = {
          compare.offset,
          compare.exact,
          compare.score,
          compare.recently_used,
          compare.kind,
          compare.order,
        },
      },
      sources = cmp.config.sources({
        -- { name = "nvim_lsp", trigger_characters = { "-" } },
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
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
  end,
}
