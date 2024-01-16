local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
  lspconfig.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities or {},
    on_init = function(client)
      local path = client.workspace_folders[1].name
      if
        not vim.loop.fs_stat(path .. "/.luarc.json")
        and not vim.loop.fs_stat(path .. "/.luarc.jsonc")
      then
        client.config.settings =
          vim.tbl_deep_extend("force", client.config.settings, {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              runtime = {
                version = "LuaJIT",
              },
              diagnostics = {
                globals = {
                  "vim",
                  "use",
                  "describe",
                  "it",
                  "assert",
                  "before_each",
                  "after_each",
                  "hs", -- hammerspoon
                },
              },
              workspace = {
                checkThirdParty = false,
                preloadFileSize = 100000,
                maxPreload = 10000,
                library = {
                  vim.env.VIMRUNTIME,
                },
                -- library = {
                --   vim.api.nvim_get_runtime_file("", true),
                -- },
              },
              hint = {
                enable = true,
              },
            },
          })

        client.notify(
          "workspace/didChangeConfiguration",
          { settings = client.config.settings }
        )
      end
      return true
    end,
  })
end

return M
