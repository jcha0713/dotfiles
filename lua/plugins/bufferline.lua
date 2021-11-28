local bufferline = require('bufferline')

bufferline.setup {
  options = {
    diagnostics = "nvim_lsp",
    offsets = {{filetype = "NvimTree", text = "File Explorer", text_align = "left" }},
    always_show_bufferline = false,
  }
}
