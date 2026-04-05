require("blink.cmp").setup({
  cmdline = {
    keymap = { preset = "inherit" },
    completion = { menu = { auto_show = true } },
  },
  keymap = {
    preset = "default",
  },
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = {
    list = { selection = { preselect = true, auto_insert = false } },
    documentation = { auto_show = true },
    ghost_text = {
      enabled = true,
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = {
    implementation = "prefer_rust_with_warning",
  },
})
