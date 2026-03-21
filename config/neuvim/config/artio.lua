require("artio").setup({
  opts = {
    use_icons = true,
  },
  mappings = {
    ["<C-n>"] = "down",
    ["<C-p>"] = "up",
    ["<cr>"] = "accept",
    ["<esc>"] = "cancel",
    ["<tab>"] = "mark",
    ["<c-g>"] = "togglelive",
    ["<c-l>"] = "togglepreview",
    ["<c-q>"] = "setqflist",
    ["<m-q>"] = "setqflistmark",
    ["<c-s>"] = "split",
    ["<c-v>"] = "vsplit",
    ["<c-t>"] = "tabnew",
  }
})

vim.ui.select = require("artio").select

---@param fn fun(item: artio.Picker.item): integer
---@return table<string, artio.Picker.action>
---@see https://github.com/comfysage/artio.nvim/blob/main/lua/artio/utils.lua#L84
local function fileactions(fn)
  return {
    split = require("artio").wrap(function(self)
      self:cancel()
    end, function(self)
      local item = self:getcurrent()
      if not item then
        return
      end
      local buf = fn(item)
      vim.api.nvim_open_win(buf, true, { win = -1, vertical = false })
    end),
    vsplit = require("artio").wrap(function(self)
      self:cancel()
    end, function(self)
      local item = self:getcurrent()
      if not item then
        return
      end
      local buf = fn(item)
      vim.api.nvim_open_win(buf, true, { win = -1, vertical = true })
    end),
    tabnew = require("artio").wrap(function(self)
      self:cancel()
    end, function(self)
      local item = self:getcurrent()
      if not item then
        return
      end
      local buf = fn(item)
      vim.api.nvim_cmd({
        cmd = "split",
        args = { ("+%dbuf"):format(buf) },
        ---@diagnostic disable-next-line: missing-fields
        mods = {
          tab = 1,
          silent = true,
        },
      }, {
        output = false,
      })
    end),
  }
end

vim.keymap.set("n", "<leader>ff", function()
  require('artio.builtins').smart({
    actions = fileactions(function(item) 
      return vim.fn.bufnr(item.v, true)
    end)
  })
end)

vim.keymap.set("n", "<leader>fh", function()
  require('artio.builtins').helptags({
    actions = fileactions(function(item) 
      return vim.fn.bufnr(item.v, true)
    end)
  })
end)

vim.keymap.set("n", "<leader>fo", function()
  require('artio.builtins').oldfiles({
    actions = fileactions(function(item) 
      return vim.fn.bufnr(item.v, true)
    end)
  })
end)

vim.keymap.set("n", "<leader>gr", function()
  require('artio.builtins').grep({
    actions = fileactions(function(item) 
      return vim.fn.bufnr(item.v, true)
    end)
  })
end)

