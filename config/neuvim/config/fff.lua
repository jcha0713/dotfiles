vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(event)
    if event.data.updated then
      require('fff.download').download_or_build_binary()
    end
  end,
})

vim.g.fff = {
  lazy_sync = true,
}

vim.keymap.set("n", "<leader>gr", function() require('fff').live_grep() end, { desc = "fff live grep" } )
