-- many lines taken from https://github.com/Quitlox/dotfiles/blob/ee780039dfddae1c1c10b5c5662f80ffae8d4b01/private_dot_config/exact_nvim/exact_lua/exact_quitlox/exact_plugins/exact_ide/exact_lsp/formatting.lua

-- local init_msg_progress = function(title, msg)
--   return require("fidget.progress").handle.create({
--     title = title,
--     message = msg,
--     lsp_client = { name = "conform" }, -- the fake lsp client name
--     percentage = nil, -- skip percentage field
--   })
-- end

local format_args = {
  timeout_ms = 3000,
  lsp_fallback = "fallback",
}

-- https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#run-the-first-available-formatter-followed-by-more-formatters
---@param bufnr integer
---@param ... string
---@return string
local function first(bufnr, ...)
  local conform = require("conform")
  for i = 1, select("#", ...) do
    local formatter = select(i, ...)
    if conform.get_formatter_info(formatter, bufnr).available then
      return formatter
    end
  end
  return select(1, ...)
end

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

  ---@class (exact) conform.FormatterInfo
  ---@field name string
  ---@field command string
  ---@field cwd? string
  ---@field available boolean
  ---@field available_msg? string
  ---@field error? boolean

  ---@type conform.FormatterInfo[] | boolean
  local active_fmts = conform.list_formatters_to_run(bufnr)
  local formatter_name = ""

  if active_fmts == false or #active_fmts <= 0 then
    formatter_name = "lsp"
  else
    formatter_name = active_fmts[1].name
  end

  local fmt_info = "fmt: " .. formatter_name
  -- local msg_handle = init_msg_progress(fmt_info)

  return format_args,
    function(err)
      if err then
        if type(err) == "table" then
          err = err.message
        end
        vim.notify(err, vim.log.levels.WARN, { title = fmt_info })
      end
      -- msg_handle:finish()
    end
end

return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      astro = { "prettierd", "prettier" },
      javascript = function(bufnr)
        return { first(bufnr, "biome", "prettierd", "prettier") }
      end,
      typescript = function(bufnr)
        return { first(bufnr, "biome", "prettierd", "prettier") }
      end,
      javascriptreact = function(bufnr)
        return { first(bufnr, "biome", "prettierd", "prettier") }
      end,
      typescriptreact = function(bufnr)
        return { first(bufnr, "biome", "prettierd", "prettier") }
      end,
      css = { "prettierd", "prettier" },
      html = { "prettierd", "prettier" },
      markdown = function(bufnr)
        return { first(bufnr, "prettierd", "prettier"), "injected" }
      end,
      yaml = { "prettierd", "prettier" },
      json = { "prettierd", "prettier" },
      jsonc = { "prettierd", "prettier" },
      svelt = { "prettierd", "prettier" },
      lua = { "stylua" },
      nim = { "nph" },
      nix = { "nixfmt" },
    },
    stop_after_first = true,
    default_format_opts = {
      lsp_format = "fallback",
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
    -- FIX: this does not work
    nph = {
      command = "nph",
      args = { "." },
      stdin = false,
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
