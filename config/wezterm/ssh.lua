local M = {}

M.set_ssh_domains = function(config)
  config.ssh_domains = {
    {
      name = "jcha-mini",
      remote_address = "jcha-mini",
    },
  }
end

return M
