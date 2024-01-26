local u = require("modules.utils")
local lsp = vim.lsp
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = vim.tbl_deep_extend(
  "force",
  vim.lsp.protocol.make_client_capabilities(),
  require("cmp_nvim_lsp").default_capabilities()
)

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

local orig_util_open_floating_preview = lsp.util.open_floating_preview
function lsp.util.open_floating_preview(contents, syntax, opts, ...)
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

local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon .. " ", texthl = hl, numhl = hl })
end

local win = require("lspconfig.ui.windows")
local _default_opts = win.default_opts

win.default_opts = function(options)
  local opts = _default_opts(options)
  opts.border = "rounded"
  return opts
end

local on_attach = function(client, bufnr)
  -- commands
  u.lua_command("LspFormatting", "vim.lsp.buf.format()")
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
  u.lua_command("LspSignatureHelp", "vim.lsp.buf.signature_help()")

  -- bindings
  u.map("n", "gD", ":LspDec<CR>")
  u.map("n", "gd", "<cmd>TroubleToggle lsp_definitions<CR>")
  u.map("n", "<Leader>rn", ":LspRename<CR>")
  u.map("n", "<leader>gy", "<cmd>TroubleToggle lsp_type_definitions<CR>")
  u.map("n", "H", ":LspHover<CR>")
  u.map("n", "dk", ":LspDiagPrev<CR>")
  u.map("n", "dj", ":LspDiagNext<CR>")
  u.map("n", "da", ":LspDiagOpen<CR>")
  u.map("n", "<Leader>dl", ":LspDiagLine<CR>")
  u.map("n", "<leader>ca", ":LspCodeAction<CR>")
  u.map("v", "<leader>ca", ":LspRangeCodeAction<CR>")
  u.map("n", "<leader>fr", "<cmd>TroubleToggle lsp_references<CR>")
  u.map("n", "<leader>rr", ":RustRunnable<CR>")
  u.map("i", "<C-s>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")

  if client.name == "tsserver" then
    client.server_capabilities.documentFormattingProvider = false
  end

  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(0, true)
  end

  -- hide until https://github.com/ray-x/lsp_signature.nvim/issues/276 is fixed
  -- require("lsp_signature").on_attach({
  --   bind = true, -- This is mandatory, otherwise border config won't get registered.
  --   handler_opts = {
  --     border = "rounded",
  --   },
  -- }, bufnr)

  require("illuminate").on_attach(client)
end

local servers = vim.api.nvim_get_var("lsp_servers")

for _, server_name in ipairs(servers) do
  if server_name == "rust_analyzer" then
    local ok, rust = pcall(require, "rustaceanvim")
    if not ok then
      goto continue
    end

    vim.g.rustaceanvim =
      require("modules.lsp.rust_analyzer").get_config(on_attach)

    goto continue
  end

  local server = "modules.lsp." .. server_name
  require(server).setup(on_attach, capabilities)
  ::continue::
end
