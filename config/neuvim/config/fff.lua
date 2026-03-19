vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(event)
    if event.data.updated then
      vim.system({ "nix run .#release" })
    end
  end,
})

vim.g.fff = {
  lazy_sync = true,
}

require('fff').setup({

})

vim.keymap.set("n", "<leader>gr", function() require('fff').live_grep() end, { desc = "fff live grep" } )
