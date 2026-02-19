local M = {}

M.set_settings = function(config)
  config.enable_kitty_keyboard = true
  config.enable_csi_u_key_encoding = false

  -- Disable font fallback notifications to prevent Unicode crash bug
  -- See: https://github.com/NixOS/nixpkgs/issues/384729
  config.warn_about_missing_glyphs = false

  -- Force Wayland backend for proper clipboard integration
  config.enable_wayland = true

  -- Clipboard settings
  config.canonicalize_pasted_newlines = "None"
end

return M
