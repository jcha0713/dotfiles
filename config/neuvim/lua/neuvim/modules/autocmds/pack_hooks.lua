local M = {}

function M.init()
  vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(event)
      local name, kind = event.data.spec.name, event.data.kind
      if name == "cursortab" and (kind == "install" or kind == "update") then
        vim
          .system({ "sh", "-c", "cd server && go build" }, { cwd = event.data.path })
          :wait()
      end

      if name == "treesitter" and kind == "update" then
        vim.cmd("TSUpdate")
      end
    end,
  })
end

return M
