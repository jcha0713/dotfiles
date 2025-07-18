local u = require("modules.utils")
local lsp = vim.lsp
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = vim.tbl_deep_extend(
  "force",
  vim.lsp.protocol.make_client_capabilities(),
  require("cmp_nvim_lsp").default_capabilities()
)

local orig_util_open_floating_preview = lsp.util.open_floating_preview

---@diagnostic disable-next-line: duplicate-set-field
function lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  -- opts.border = opts.border or border
  opts.border = "rounded"
  opts.max_width = opts.max_width or 80
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

vim.diagnostic.config({
  float = {
    source = true,
  },
  virtual_lines = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
    linehl = {
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",
    },
    numhl = {
      [vim.diagnostic.severity.WARN] = "WarningMsg",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = false,
})

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
  u.lua_command(
    "LspDiagPrev",
    "vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })"
  )
  u.lua_command(
    "LspDiagNext",
    "vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })"
  )
  u.lua_command("LspDiagOpen", "vim.diagnostic.open_float({border='rounded'})")
  u.lua_command(
    "LspDiagLine",
    "vim.diagnostic.open_float(nil, global.lsp.border_opts)"
  )
  u.lua_command("LspTypeDef", "vim.lsp.buf.type_definition()")
  u.lua_command("LspDec", "vim.lsp.buf.declaration()")
  u.lua_command("LspDef", "vim.lsp.buf.definition()")
  u.lua_command("LspFindRef", "vim.lsp.buf.references()")
  u.lua_command("LspCodeAction", "require('actions-preview').code_actions()")
  u.lua_command(
    "LspRangeCodeAction",
    "require('actions-preview').code_actions()"
  )
  u.lua_command("LspSignatureHelp", "vim.lsp.buf.signature_help()")

  -- bindings
  -- hover H -> K
  -- rename <leader>rn -> grn
  -- code_actions <leader>ca -> gra
  -- reference <leader>fr -> grr
  -- implementation none -> gri
  -- signature_help <C-s> -> <C-s>
  u.map("n", "gD", ":LspDec<CR>")
  u.map("n", "gd", ":Telescope lsp_definitions<CR>")
  u.map("n", "gic", ":Telescope lsp_incoming_calls<CR>")
  u.map("n", "goc", ":Telescope lsp_outgoing_calls<CR>")
  u.map("n", "gra", ":LspCodeAction<CR>")
  u.map("n", "<leader>gy", "<cmd>TroubleToggle lsp_type_definitions<CR>")
  u.map("n", "H", ":LspHover<CR>")
  u.map("n", "dk", ":LspDiagPrev<CR>")
  u.map("n", "dj", ":LspDiagNext<CR>")
  u.map("n", "da", ":LspDiagOpen<CR>")
  u.map("n", "<Leader>dl", ":LspDiagLine<CR>")
  u.map("n", "<leader>hi", function()
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(nil))
    else
      vim.notify("inlayHintProvider is not enabled", vim.log.levels.WARN, {})
    end
  end, { desc = "Toggle inlay hints" })

  -- rust
  u.map("n", "<leader>rr", ":RustRunnable<CR>")
  u.map("n", "<leader>ro", ":RustLsp openDocs<CR>")

  if client.name == "tsserver" then
    client.server_capabilities.documentFormattingProvider = false
  end
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

local lspconfig = require("lspconfig")
local config = require("lspconfig.configs")

if not config.task then
  config.task = {
    default_config = {
      cmd = {
        "haja-lsp", -- linked via `bun link`
      },
      root_dir = lspconfig.util.root_pattern(".git"),
      filetypes = { "markdown" },
    },
  }
end

-- require("modules.lsp.task").setup(on_attach, capabilities)
