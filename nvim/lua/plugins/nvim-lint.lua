return {
  "mfussenegger/nvim-lint",
  event = {
    "BufReadPre",
    "BufNewFile",
  },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      astro = { "eslint_d" },
      javascript = { "biomejs", "eslint_d" },
      typescript = { "biomejs", "eslint_d" },
      javascriptreact = { "biomejs", "eslint_d" },
      typescriptreact = { "biomejs", "eslint_d" },
      -- markdown = { "vale" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", {
      clear = true,
    })

    vim.api.nvim_create_autocmd({
      "BufEnter",
      "BufWritePost",
      "TextChanged",
      "InsertLeave",
    }, {
      group = lint_augroup,
      callback = function()
        if
          vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript"
        then
          local root_directory =
            require("utils").find_root_directory("biome.json")

          if root_directory then
            lint.try_lint("biomejs")
          end

          return
        end

        pcall(require, "lint.try_lint")
        -- lint.try_lint()
      end,
    })
  end,
}
