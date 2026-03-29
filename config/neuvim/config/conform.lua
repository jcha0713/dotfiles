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

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("neuvim.fmt", { clear = true }),
  callback = function(args)
    local bufnr = args.buf

    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      vim.notify("autoformat is disabled", vim.log.levels.WARN)
      return
    end

    local bufname = vim.api.nvim_buf_get_name(bufnr)

    if bufname:match("/node_modules/") then
      vim.notify(
        "Neovim does not format codes inside /node_modules",
        vim.log.levels.WARN
      )
      return
    end

    require("conform").format({
      bufnr = args.buf,
      timeout_ms = 3000,
    })
  end,
})

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})

require("conform").setup({
  formatters_by_ft = {
    javascript = function(bufnr)
      return { first(bufnr, "oxfmt") }
    end,
    typescript = function(bufnr)
      return { first(bufnr, "oxfmt") }
    end,
    javascriptreact = function(bufnr)
      return { first(bufnr, "oxfmt") }
    end,
    typescriptreact = function(bufnr)
      return { first(bufnr, "oxfmt") }
    end,
    css = { "oxfmt" },
    html = { "oxfmt" },
    markdown = function(bufnr)
      return { first(bufnr, "oxfmt"), "injected" }
    end,
    yaml = { "oxfmt" },
    json = { "oxfmt" },
    jsonc = { "oxfmt" },
    lua = { "stylua" },
    nix = { "nixfmt" },
  },
  stop_after_first = true,
  default_format_opts = {
    lsp_format = "fallback",
  },
})
