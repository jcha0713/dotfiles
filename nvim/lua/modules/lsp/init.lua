local u = require("modules.utils")
local lspconfig = require("lspconfig")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true

local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      -- apply whatever logic you want (in this example, we'll only use null-ls)
      return client.name == "null-ls" or client.name == "rust_analyzer"
    end,
    bufnr = bufnr,
  })
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local on_attach = function(client, bufnr)
  -- commands
  u.lua_command("LspFormatting", "vim.lsp.buf.formatting()")
  u.lua_command("LspHover", "vim.lsp.buf.hover()")
  u.lua_command("LspRename", "vim.lsp.buf.rename()")
  u.lua_command("LspDiagPrev", "vim.diagnostic.goto_prev()")
  u.lua_command("LspDiagNext", "vim.diagnostic.goto_next()")
  u.lua_command(
    "LspDiagOpen",
    "vim.diagnostic.open_float({border='rounded', focus=false})"
  )
  u.lua_command(
    "LspDiagLine",
    "vim.diagnostic.open_float(nil, global.lsp.border_opts)"
  )
  u.lua_command("LspTypeDef", "vim.lsp.buf.type_definition()")
  u.lua_command("LspDec", "vim.lsp.buf.declaration()")
  u.lua_command("LspDef", "vim.lsp.buf.definition()")
  u.lua_command("LspCodeAction", "vim.lsp.buf.code_action()")

  -- bindings
  u.buf_map("n", "gD", ":LspDec<CR>", nil, bufnr)
  u.buf_map("n", "gd", ":LspDef<CR>", nil, bufnr)
  u.buf_map("n", "<Leader>rn", ":LspRename<CR>", nil, bufnr)
  u.buf_map("n", "<Leader>td", ":LspTypeDef<CR>", nil, bufnr)
  u.buf_map("n", "H", ":LspHover<CR>", nil, bufnr)
  u.buf_map("n", "dk", ":LspDiagPrev<CR>", nil, bufnr)
  u.buf_map("n", "dj", ":LspDiagNext<CR>", nil, bufnr)
  u.buf_map("n", "da", ":LspDiagOpen<CR>", nil, bufnr)
  u.buf_map("n", "<Leader>dl", ":LspDiagLine<CR>", nil, bufnr)
  u.buf_map("n", "<leader>ca", ":LspCodeAction<CR>", nil, bufnr)

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

local servers = {
  "astro",
  "cssls",
  "cssmodules_ls",
  "html",
  "jsonls",
  "null-ls",
  "prismals",
  "rust_analyzer",
  "solang",
  "sumneko_lua",
  "svelte",
  "tailwindcss",
  "tsserver",
}

for _, lsp in ipairs(servers) do
  if lsp == "rust_analyzer" then
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

  local server = "modules.lsp." .. lsp
  require(server).setup(on_attach, capabilities)
  ::continue::
end

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
