local u = require("modules.utils")
local lsp = vim.lsp

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true

local border = {
  { "╭", "FloatBorder" },
  { "─", "FloatBorder" },
  { "╮", "FloatBorder" },
  { "│", "FloatBorder" },
  { "╯", "FloatBorder" },
  { "─", "FloatBorder" },
  { "╰", "FloatBorder" },
  { "│", "FloatBorder" },
}

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

vim.diagnostic.config({
  float = {
    source = "always",
    show_header = true,
  },
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = false,
})

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local win = require("lspconfig.ui.windows")
local _default_opts = win.default_opts

win.default_opts = function(options)
  local opts = _default_opts(options)
  opts.border = "rounded"
  return opts
end

local eslint_disabled_buffers = {}

-- track buffers that eslint can't format to use prettier instead
lsp.handlers["textDocument/publishDiagnostics"] =
  function(_, result, ctx, config)
    local client = lsp.get_client_by_id(ctx.client_id)
    if not (client and client.name == "eslint") then
      goto done
    end

    for _, diagnostic in ipairs(result.diagnostics) do
      if
        diagnostic.message:find("The file does not match your project config")
      then
        local bufnr = vim.uri_to_bufnr(result.uri)
        eslint_disabled_buffers[bufnr] = true
      end
    end

    ::done::
    return lsp.diagnostic.on_publish_diagnostics(nil, result, ctx, config)
  end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- local lsp_formatting = function(bufnr)
--   vim.lsp.buf.format({
--     bufnr = bufnr,
--     filter = function(client)
--       return client.name == "null-ls" or client.name == "rust_analyzer"
--     end,
--   })
-- end

local lsp_formatting = function(bufnr)
  lsp.buf.format({
    bufnr = bufnr,
    filter = function(client)
      if client.name == "rust_analyzer" then
        return true
      end

      if client.name == "eslint" then
        return not eslint_disabled_buffers[bufnr]
      end

      if client.name == "null-ls" then
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
        return not u.some(clients, function(_, other_client)
          return other_client.name == "eslint"
            and not eslint_disabled_buffers[bufnr]
        end)
      end
    end,
  })
end

local on_attach = function(client, bufnr)
  -- commands
  u.lua_command("LspFormatting", "vim.lsp.buf.formatting()")
  u.lua_command("LspHover", "vim.lsp.buf.hover()")
  u.lua_command("LspRename", "vim.lsp.buf.rename()")
  u.lua_command("LspDiagPrev", "vim.diagnostic.goto_prev()")
  u.lua_command("LspDiagNext", "vim.diagnostic.goto_next()")
  u.lua_command("LspDiagOpen", "vim.diagnostic.open_float({border='rounded'})")
  u.lua_command(
    "LspDiagLine",
    "vim.diagnostic.open_float(nil, global.lsp.border_opts)"
  )
  u.lua_command("LspTypeDef", "vim.lsp.buf.type_definition()")
  u.lua_command("LspDec", "vim.lsp.buf.declaration()")
  u.lua_command("LspDef", "vim.lsp.buf.definition()")
  u.lua_command("LspFindRef", "vim.lsp.buf.references()")
  u.lua_command("LspCodeAction", "require('cosmic-ui').code_actions()<cr>")
  u.lua_command(
    "LspRangeCodeAction",
    "require('cosmic-ui').range_code_actions()"
  )

  -- bindings
  u.buf_map("n", "gD", ":LspDec<CR>", nil, bufnr)
  -- u.buf_map("n", "gd", ":LspDef<CR>", nil, bufnr)
  u.buf_map("n", "gd", "<cmd>TroubleToggle lsp_definitions<CR>", nil, bufnr)
  u.buf_map("n", "<Leader>rn", ":LspRename<CR>", nil, bufnr)
  -- u.buf_map("n", "<Leader>td", ":LspTypeDef<CR>", nil, bufnr)
  u.buf_map(
    "n",
    "<leader>td",
    "<cmd>TroubleToggle lsp_type_definitions<CR>",
    nil,
    bufnr
  )
  u.buf_map("n", "H", ":LspHover<CR>", nil, bufnr)
  u.buf_map("n", "dk", ":LspDiagPrev<CR>", nil, bufnr)
  u.buf_map("n", "dj", ":LspDiagNext<CR>", nil, bufnr)
  u.buf_map("n", "da", ":LspDiagOpen<CR>", nil, bufnr)
  u.buf_map("n", "<Leader>dl", ":LspDiagLine<CR>", nil, bufnr)
  u.buf_map("n", "<leader>ca", ":LspCodeAction<CR>", nil, bufnr)
  -- u.buf_map("n", "<leader>fr", ":LspFindRef<CR>", nil, bufnr)
  u.buf_map(
    "n",
    "<leader>fr",
    "<cmd>TroubleToggle lsp_references<CR>",
    nil,
    bufnr
  )
  u.buf_map("v", "<leader>ca", ":LspRangeCodeAction<CR>", nil, bufnr)
  u.buf_map("n", "<leader>rr", ":RustRun<CR>", nil, bufnr)

  -- format file on save
  -- client.server_capabilities.documentFormattingProvider = true
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        lsp_formatting(bufnr)
      end,
    })
  end

  -- if client.resolved_capabilities.completion then
  --   vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
  -- end

  require("lsp_signature").on_attach({
    bind = true, -- This is mandatory, otherwise border config won't get registered.
    handler_opts = {
      border = "rounded",
    },
  }, bufnr)

  require("illuminate").on_attach(client)
end

-- Configure sumneko_lua to support neovim Lua runtime APIs
require("neodev").setup()

local servers = {
  "astro",
  "bashls",
  "cssls",
  -- "cssmodules_ls",
  "eslint",
  "gopls",
  "html",
  "jsonls",
  "nimls",
  "null-ls",
  "prismals",
  "rust_analyzer",
  "solang",
  "sourcekit",
  "sumneko_lua",
  "svelte",
  "tailwindcss",
  "tsserver",
  "unocss",
}

for _, server_name in ipairs(servers) do
  if server_name == "rust_analyzer" then
    local ok, rt = pcall(require, "rust-tools")
    if not ok then
      goto continue
    end

    rt.setup({
      server = {
        standalone = false,
        on_attach = on_attach,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      },
    })

    goto continue
  end

  local server = "modules.lsp." .. server_name
  require(server).setup(on_attach, capabilities)
  ::continue::
end
