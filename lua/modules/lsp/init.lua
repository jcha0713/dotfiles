local u = require('modules.utils')

local on_attach = function(client, bufnr)
    -- commands
    u.lua_command("LspFormatting", "vim.lsp.buf.formatting()")
    u.lua_command("LspHover", "vim.lsp.buf.hover()")
    u.lua_command("LspRename", "vim.lsp.buf.rename()")
    u.lua_command("LspDiagPrev", "vim.diagnostic.goto_prev()")
    u.lua_command("LspDiagNext", "vim.diagnostic.goto_next()")
    u.lua_command("LspDiagLine", "vim.diagnostic.open_float(nil, global.lsp.border_opts)")
    u.lua_command("LspSignatureHelp", "vim.lsp.buf.signature_help()")
    u.lua_command("LspTypeDef", "vim.lsp.buf.type_definition()")

    -- bindings
    u.buf_map("n", "gi", ":LspRename<CR>", nil, bufnr)
    u.buf_map("n", "gy", ":LspTypeDef<CR>", nil, bufnr)
    u.buf_map("n", "H", ":LspHover<CR>", nil, bufnr)
    u.buf_map("n", "[a", ":LspDiagPrev<CR>", nil, bufnr)
    u.buf_map("n", "]a", ":LspDiagNext<CR>", nil, bufnr)
    u.buf_map("n", "<Leader>a", ":LspDiagLine<CR>", nil, bufnr)
    u.buf_map("i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>", nil, bufnr)

    -- telescope
    u.buf_map("n", "gr", ":LspRef<CR>", nil, bufnr)
    u.buf_map("n", "gd", ":LspDef<CR>", nil, bufnr)
    u.buf_map("n", "ga", ":LspAct<CR>", nil, bufnr)
    u.buf_map("v", "ga", "<Esc><cmd> LspRangeAct<CR>", nil, bufnr)

    if client.resolved_capabilities.document_formatting then
        vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
    end

    if client.resolved_capabilities.completion then
        vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
    end

    require("illuminate").on_attach(client)

end

require("modules.lsp.tsserver").setup(on_attach)
require("modules.lsp.jsonls").setup(on_attach)
require("modules.lsp.svelte").setup(on_attach)
require("modules.lsp.html").setup(on_attach)
require("modules.lsp.cssls").setup(on_attach)
require("modules.lsp.tailwindcss").setup(on_attach)
require("modules.lsp.null-ls").setup(on_attach)
require("modules.lsp.sumneko").setup(on_attach)

local configs = require 'lspconfig.configs'
local util = require 'lspconfig.util'

local server_name = 'astro'

configs[server_name] = {
  default_config = {
    cmd = { 'astro-ls', '--stdio' },
    filetypes = { 'astro' },
    root_dir = function(fname)
      return util.root_pattern('package.json', 'tsconfig.json', 'jsconfig.json', '.git')(fname)
    end,
  },
  docs = {
    package_json = 'https://raw.githubusercontent.com/withastro/astro-language-tools/main/packages/vscode/package.json',
    root_dir = [[root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")]],
  }
}

require("modules.lsp.astro").setup(on_attach)
