local plugins = {
  -- "winbar",
  -- "idg",
  "fetch_title",
  "clipboard",
  "nix_shell",
}

if vim.g.nvim_mode == "zk" then
  return
end

for _, plugin in ipairs(plugins) do
  require("modules.custom." .. plugin).setup()
end
