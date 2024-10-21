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

    local function find_root_directory(file_name)
      local file_path = vim.fn.findfile(file_name, ".;")
      if file_path == "" then
        return nil
      end
      return vim.fn.fnamemodify(file_path, ":h")
    end

    vim.api.nvim_create_autocmd({
      "BufEnter",
      "BufWritePost",
      "TextChanged",
      "InsertLeave",
    }, {
      group = lint_augroup,
      callback = function()
        local root_directory = find_root_directory("biome.json")

        if root_directory then
          lint.try_lint("biomejs")
        else
          lint.try_lint()
        end
      end,
    })
  end,
}
