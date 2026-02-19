local M = {}

M.set_ssh_domains = function(config)
  config.ssh_domains = {
    {
      name = "jchamini",
      remote_address = "jchamini",
    },
  }
end

return M
