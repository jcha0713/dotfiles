-- many lines taken from https://github.com/Quitlox/dotfiles/blob/ee780039dfddae1c1c10b5c5662f80ffae8d4b01/private_dot_config/exact_nvim/exact_lua/exact_quitlox/exact_plugins/exact_ide/exact_lsp/formatting.lua

local init_msg_progress = function(title, msg)
  return require("fidget.progress").handle.create({
    title = title,
    message = msg,
    lsp_client = { name = "conform" }, -- the fake lsp client name
    percentage = nil, -- skip percentage field
  })
end

local format_args = {
  timeout_ms = 3000,
  lsp_fallback = true,
}

local format_on_save = function(args, bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  if bufname:match("/node_modules/") then
    vim.notify(
      "Neovim does not format codes inside /node_modules",
      vim.log.levels.WARN
    )
    return
  end

  local conform = require("conform")
  local fmts = conform.list_formatters()
  local active_fmts = {}

  if not vim.tbl_isempty(fmts) then
    active_fmts = vim.tbl_map(function(f)
      return f.name
    end, fmts)
  elseif conform.will_fallback_lsp(format_args) then
    active_fmts = { "lsp" }
  else
    return
  end

  local fmt_info = "fmt: " .. table.concat(active_fmts, "/")
  local msg_handle = init_msg_progress(fmt_info)

  return format_args,
    function(err)
      if err then
        vim.notify(err, vim.log.levels.WARN, { title = fmt_info })
      end
      msg_handle:finish()
    end
end

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
      return format_on_save(format_args, bufnr)
    end,
    formatters = {
      prettierd = {
        env = {
          PRETTIERD_DEFAULT_CONFIG = vim.fn.stdpath("config")
            .. "/utils/linter-config/.prettierrc.json",
          -- PRETTIERD_LOCAL_PRETTIER_ONLY = "1",
        },
        -- prepend_args = function(self, ctx)
        --   local args = {}
        --   local hasTailwindPrettierPlugin =
        --     vim.fs.find("node_modules/prettier-plugin-tailwindcss", {
        --       upward = true,
        --       path = ctx.dirname,
        --       type = "directory",
        --     })[1]
        --
        --   if hasTailwindPrettierPlugin then
        --     vim.list_extend(args, { "--plugin", "prettier-plugin-tailwindcss" })
        --   end
        --   return args
        -- end,
      },
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
        timeout_ms = 3000,
      })
    end, {
      desc = "Format file",
    })
  end,
}
