-- (attribute (attribute_name) @attr_name (#eq? @attr_name "class") (quoted_attribute_value (attribute_value) @attr_value (#offset! @attr_value)))
local M = {}

local bufnr = vim.api.nvim_get_current_buf()
local cursor_pos = vim.api.nvim_win_get_cursor(0)
local row, col = unpack(cursor_pos)

local parser = vim.treesitter.get_parser(bufnr, "html")
local tree = parser:parse()
local root = tree[1]:root()

local query = vim.treesitter.query.parse_query(
  "html",
  [[
    (attribute (attribute_name) @attr_name (quoted_attribute_value (attribute_value) @attr_value (#offset! @attr_value)))
  ]]
)

for _, captures, metadata in query:iter_matches(root, bufnr, row - 1, row) do
  if vim.treesitter.get_node_text(captures[1], bufnr) == "class" then
    P(vim.treesitter.get_node_text(captures[2], bufnr))
    P(metadata)
  end
end

return M
