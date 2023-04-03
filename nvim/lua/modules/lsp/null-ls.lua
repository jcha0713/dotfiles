local null_ls = require("null-ls")
local nim_src = require("modules.lsp.nim_src")
local b = null_ls.builtins

local with_root_file = function(...)
  local files = { ... }
  return function(utils)
    return utils.root_has_file(files)
  end
end

local xo_opts = {
  condition = with_root_file("node_modules/xo/index.js"),
  diagnostics_format = "[#{c}] #{m} (#{s})",
}

local dprint_opts = {
  condition = with_root_file("dprint.json"),
  diagnostics_format = "[#{c}] #{m} (#{s})",
}

local sources = {
  -- nim_src,
  b.formatting.nimpretty,
  b.code_actions.xo.with(xo_opts),
  b.diagnostics.xo.with(xo_opts),
  b.formatting.stylua,
  b.formatting.gofmt,
  b.formatting.goimports,
  b.formatting.dprint.with(dprint_opts),
  -- b.formatting.prettier.with({
  --   prefer_local = "node_modules/.bin",
  --   filetypes = {
  --     "html",
  --     "astro",
  --     "json",
  --     "jsonc",
  --     "svelte",
  --     "markdown",
  --     "css",
  --     "javascript",
  --     "javascriptreact",
  --     "typescript",
  --     "typescriptreact",
  --   },
  -- }),
  b.formatting.prettierd.with({
    env = {
      PRETTIERD_DEFAULT_CONFIG = vim.fn.expand(
        "$HOME/.config/nvim/utils/linter-config/.prettierrc.json"
      ),
    },
    filetypes = {
      "html",
      "astro",
      "json",
      "jsonc",
      "svelte",
      "markdown",
      "css",
      "scss",
      "javascript",
      "javascriptreact",
      "twig",
      "typescript",
      "typescriptreact",
    },
  }),
  b.hover.dictionary,
}

local M = {}

local method = null_ls.methods.DIAGNOSTICS

M.setup = function(on_attach)
  null_ls.setup({
    -- debug = true,
    sources = sources,
    on_attach = on_attach,
  })
end

function M.list_registered_providers_names(filetype)
  local s = require("null-ls.sources")
  local available_sources = s.get_available(filetype)
  local registered = {}
  for _, source in ipairs(available_sources) do
    for s_method in pairs(source.methods) do
      registered[s_method] = registered[s_method] or {}
      table.insert(registered[s_method], source.name)
    end
  end
  return registered
end

function M.list_registered(filetype)
  local registered_providers = M.list_registered_providers_names(filetype)
  return registered_providers[method] or {}
end

return M
