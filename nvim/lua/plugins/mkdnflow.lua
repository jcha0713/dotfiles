require("mkdnflow").setup({
  mappings = {
    MkdnEnter = false,
    MkdnFollowLink = { "n", "<leader>fl" },

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
