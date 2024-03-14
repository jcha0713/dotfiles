local M = {}

M.set_settings = function(config)
  config.enable_kitty_keyboard = true
  config.enable_csi_u_key_encoding = false
end

return M
