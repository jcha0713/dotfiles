local M = {}

M.get_config = function(on_attach)
  local config = {
    server = {
      on_attach = on_attach,
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
          },
          checkOnSave = true,
          check = {
            enable = true,
            command = "clippy",
            features = "all",
          },
        },
      },
    },
  }

  return config
end

return M
