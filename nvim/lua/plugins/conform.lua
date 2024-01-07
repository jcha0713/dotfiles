return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      astro = { { "prettierd", "prettier" } },
      javascirpt = { { "prettierd", "prettier" } },
      typescript = { { "prettierd", "prettier" } },
      javascirptreact = { { "prettierd", "prettier" } },
      typescriptreact = { { "prettierd", "prettier" } },
      css = { { "prettierd", "prettier" } },
      html = { { "prettierd", "prettier" } },
      markdown = { { "prettierd", "prettier" } },
      yaml = { { "prettierd", "prettier" } },
      json = { { "prettierd", "prettier" } },
      jsonc = { { "prettierd", "prettier" } },
      svelt = { { "prettierd", "prettier" } },
      sh = { "shfmt" },
      lua = { "stylua" },
    },
    format_on_save = function(bufnr)
      local bufname = vim.api.nvim_buf_get_name(bufnr)

      if bufname:match("/node_modules/") then
        return
      end

      return { timeout_ms = 500, lsp_fallback = true }
    end,
    formatters = {
      dprint = {
        condition = function(ctx)
          return vim.fs.find(
            { "dprint.json" },
            { path = ctx.filename, upward = true }
          )[1]
        end,
      },
    },
  },
  config = function(_, opts)
    local conform = require("conform")

    conform.setup(opts)

    vim.keymap.set({ "n", "v" }, "<leader><leader>f", function()
      conform.format({
        lsp_fallback = true,
        timeout_ms = 500,
      })
    end, {
      desc = "Format file",
    })
  end,
}
