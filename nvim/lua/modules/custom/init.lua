local plugins = {
  "winbar",
  "idg",
}

for _, plugin in ipairs(plugins) do
  require("modules.custom." .. plugin).setup()
end
