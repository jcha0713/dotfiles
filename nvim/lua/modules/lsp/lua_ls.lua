local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
  lspconfig.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities or {},
    -- https://github.com/neovim/neovim/issues/27740
    on_init = function(client)
      local path = client.workspace_folders[1].name
      if
        vim.loop.fs_stat(path .. "/.luarc.json")
        or vim.loop.fs_stat(path .. "/.luarc.jsonc")
      then
        return
      end

      client.config.settings.Lua =
        vim.tbl_deep_extend("force", client.config.settings.Lua, {
          runtime = {
            version = "LuaJIT",
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            preloadFileSize = 100000,
            maxPreload = 10000,
            library = {
              vim.env.VIMRUNTIME,
              -- Depending on the usage, you might want to add additional paths here.
              -- "${3rd}/luv/library"
              -- "${3rd}/busted/library",
            },
            -- library = vim.api.nvim_get_runtime_file("", true)
          },
        })

      client.notify(
        "workspace/didChangeConfiguration",
        { settings = client.config.settings }
      )
    end,
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
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

        hint = {
          enable = true,
        },
      },
    },
  })
end

return M
