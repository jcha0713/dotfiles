return {
  "jakewvincent/mkdnflow.nvim",
  ft = { "markdown" },
  config = function()
    require("mkdnflow").setup({
      modules = {
        cmp = true,
      },
      -- directories with .obsidian file is a root
      -- perspective = {
      --   priority = "root",
      --   root_tell = ".obsidian",
      -- },
      links = {
        name_is_source = true,
        transform_explicit = function(input)
          input = input:gsub(" ", "-")
          return input
        end,
        -- remove leading slash when following notes
        transform_implicit = function(input)
          if input:sub(1, 1) == "/" then
            input = input.sub(input, 2)
          end
          vim.print(input)
          return input
        end,
      },
      new_file_template = {
        use_template = true,
        template = [[
---
date: {{ date }}
tag: []
---

## See Also

## Reference
]],
      },
      mappings = {
        MkdnEnter = false,
        MkdnFollowLink = { { "n", "v" }, "<leader>fl" },
        MkdnDestroyLink = { "n", "<leader>rl" },

        MkdnNextLink = false,
        MkdnPrevLink = false,
        MkdnTableNextCell = false,
        MkdnTablePrevCell = false,

        -- to the next/prev note
        MkdnGoBack = { "n", "[m" },
        MkdnGoForward = { "n", "]m" },

        -- toggle list item
        MkdnToggleToDo = { { "n", "v" }, "<leader>ti" },

        -- fold section
        MkdnFoldSection = { "n", "<leader>fo" },
        MkdnUnfoldSection = { "n", "<leader>uf" },
      },
    })
  end,
}
