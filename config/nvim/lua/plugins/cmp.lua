local cmp_kinds = {
  Text = "  ",
  Method = "  ",
  Function = "  ",
  Constructor = "  ",
  Field = "  ",
  Variable = "  ",
  Class = "  ",
  Interface = "  ",
  Module = "  ",
  Property = "  ",
  Unit = "  ",
  Value = "  ",
  Enum = "  ",
  Keyword = "  ",
  Snippet = "  ",
  Color = "  ",
  File = "  ",
  Reference = "  ",
  Folder = "  ",
  EnumMember = "  ",
  Constant = "  ",
  Struct = "  ",
  Event = "  ",
  Operator = "  ",
  TypeParameter = "  ",
}

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
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
    -- local lspkind = require("lspkind")
    local compare = require("cmp.config.compare")

    cmp.setup({
      -- completion = {
      --   completeopt = "menu,menuone,noinsert",
      -- },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      view = {
        entries = { name = "custom", selection_order = "near_cursor" },
      },
      formatting = {
        -- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#menu-type
        format = function(entry, vim_item)
          -- add icons and kind
          pcall(function()
            local lspkind = require("lspkind")
            vim_item = require("nvim-highlight-colors").format(entry, vim_item)

            vim_item.kind_symbol = (lspkind.symbolic or lspkind.get_symbol)(
              vim_item.kind
            )
            vim_item.kind = (cmp_kinds[vim_item.kind] or "") .. vim_item.kind
          end)

          vim_item.menu = ({
            fuzzy_buffer = "Buf",
            ["cmp-tw2css"] = "TailwindCSS",
            luasnip = "Snip",
            look = "Dict",
            mkdnflow = "Note",
          })[entry.source.name] or string.format(
            "%s",
            entry.source.name
          )

          if entry.source.name == "nvim_lsp" then
            local lspserver_name = nil
            pcall(function()
              lspserver_name = entry.source.source.client.name
              vim_item.menu = lspserver_name
            end)
            local filename = vim.api.nvim_get_var("filenames")[lspserver_name]
              or lspserver_name
            local icon = require("nvim-web-devicons").get_icon(filename)
            if icon then
              vim_item.menu = icon .. " " .. vim_item.menu
            end
          end

          return vim_item
        end,
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
        {
          name = "nvim_lsp",
          option = {
            markdown_oxide = {
              keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
            },
          },
        },
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
        { name = "mkdnflow" },
        { name = "cmp-tw2css" },
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
