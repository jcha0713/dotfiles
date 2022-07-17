local lspconfig = require("lspconfig")

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

local root = "/Users/jcha0713/.config/nvim/data/lua-language-server"
local binary = root .. "/bin/macOS/lua-language-server"
local settings = {
  Lua = {
    runtime = { version = "LuaJIT", path = runtime_path },
    workspace = {
      library = vim.api.nvim_get_runtime_file("", true),
      checkThirdParty = false,
      maxPreload = 10000,
    },
    -- Do not send telemetry data containing a randomized but unique identifier
    telemetry = {
      enable = false,
    },
    diagnostics = {
      enable = true,
      globals = {
        "global",
        "vim",
        "use",
        "describe",
        "it",
        "assert",
        "before_each",
        "after_each",
      },
    },
    completion = {
      showWord = "Disable",
    },
  },
}

local M = {}
M.setup = function(on_attach)
  lspconfig.sumneko_lua.setup({
    autostart = true,
    on_attach = function(client, bufnr)
      -- u.buf_map("i", ".", ".<C-x><C-o>", nil, bufnr)
      on_attach(client, bufnr)
    end,
    cmd = { binary, "-E", root .. "/main.lua" },
    settings = settings,
    flags = {
      debounce_text_changes = 150,
    },
  })
end

return M
