local lspconfig = require("lspconfig")

local M = {}

M.setup = function(on_attach, capabilities)
  lspconfig.eslint.setup({
    root_dir = lspconfig.util.root_pattern(
      ".eslintrc",
      ".eslintrc.js",
      ".eslintrc.json"
    ),
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = true
      local au_lsp = vim.api.nvim_create_augroup("eslint_lsp", { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function()
          vim.lsp.buf.format(nil)
        end,
        group = au_lsp,
      })
    end,
    capabilities = capabilities or {},
    settings = {
      codeAction = {
        showDocumentation = {
          enable = true,
        },
      },
      validate = "on",
      workingDirectories = {
        mode = "auto",
      },
      format = {
        enable = true,
      },
    },
    handlers = {
      -- this error shows up occasionally when formatting
      -- formatting actually works, so this will supress it
      ["window/showMessageRequest"] = function(_, result)
        if result.message:find("ENOENT") then
          return vim.NIL
        end

        return vim.lsp.handlers["window/showMessageRequest"](nil, result)
      end,
    },
  })
end

return M
