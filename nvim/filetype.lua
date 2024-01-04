vim.filetype.add({
  extension = {
    mdx = "markdown",
    sol = "solidity",
    nimja = "html",
    nims = "nims",
    telekasten = "markdown",
  },
  filename = {
    [".prettierrc"] = "jsonc",
    [".eslintrc"] = "jsonc",
    ["tsconfig.json"] = "jsonc",
    ["jsconfig.json"] = "jsonc",
  },
})
