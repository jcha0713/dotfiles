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

-- local eslint_disabled_buffers = {}
--
-- -- track buffers that eslint can't format to use prettier instead
-- lsp.handlers["textDocument/publishDiagnostics"] =
--   function(_, result, ctx, config)
--     local client = lsp.get_client_by_id(ctx.client_id)
--     if not (client and client.name == "eslint") then
--       goto done
--     end
--
--     -- clinet is the ESLint server
--     for _, diagnostic in ipairs(result.diagnostics) do
--       if
--         diagnostic.message:find("The file does not match your project config")
--       then
--         local bufnr = vim.uri_to_bufnr(result.uri)
--         eslint_disabled_buffers[bufnr] = true
--       end
--     end
--
--     ::done::
--     return lsp.diagnostic.on_publish_diagnostics(nil, result, ctx, config)
--   end

-- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
--
-- local lsp_formatting = function(bufnr)
--   lsp.buf.format({
--     bufnr = bufnr,
--     filter = function(client)
--       if client.name == "rust_analyzer" or client.name == "gleam" then
--         return true
--       end
--
--       if client.name == "null-ls" then
--         local clients = lsp.get_active_clients({ bufnr = bufnr })
--
--         local util = require("lspconfig.util")
--         local root_pattern = util.root_pattern
--         local files_to_search = { "dprint.json" }
--
--         local current_file = vim.api.nvim_buf_get_name(0)
--         local root_dir = root_pattern(unpack(files_to_search))(current_file)
--
--         if root_dir then
--           for _, file in ipairs(files_to_search) do
--             local file_path = root_dir .. "/" .. file
--             local file_exists = vim.loop.fs_stat(file_path) ~= nil
--             if file_exists then
--               require("null-ls").disable("prettierd")
--               break
--             end
--           end
--         end
--
--         local is_eslint_not_present = not u.some(
--           clients,
--           function(_, other_client)
--             return other_client.name == "eslint"
--               and not eslint_disabled_buffers[bufnr]
--           end
--         )
--
--         -- let me know if the formatting is done by null-ls
--         if is_eslint_not_present then
--           vim.api.nvim_echo({
--             {
--               "Formatting with null-ls",
--               "Comment",
--             },
--           }, true, {})
--         end
--
--         return is_eslint_not_present
--       end
--     end,
--   })
-- end

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

  -- if client.supports_method("textDocument/formatting") then
  --   vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
  --   vim.api.nvim_create_autocmd("BufWritePre", {
  --     group = augroup,
  --     buffer = bufnr,
  --     callback = function()
  --       lsp_formatting(bufnr)
  --     end,
  --   })
  -- end

  -- hide until https://github.com/ray-x/lsp_signature.nvim/issues/276 is fixed
  -- require("lsp_signature").on_attach({
  --   bind = true, -- This is mandatory, otherwise border config won't get registered.
  --   handler_opts = {
  --     border = "rounded",
  --   },
  -- }, bufnr)

  require("illuminate").on_attach(client)
end

-- Configure sumneko_lua to support neovim Lua runtime APIs
-- require("neodev").setup()

local servers = vim.api.nvim_get_var("lsp_servers")

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
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
            hover = {
              links = {
                enable = false,
              },
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
