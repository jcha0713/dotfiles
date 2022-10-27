-- TODO: Refactor inject_class function
-- TODO: Add remove_class that removes class attribute
-- TEST: Test with js, jsx, astro ...

local M = {}

M.inject_class = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row, col = unpack(cursor_pos)

  -- treesitter query to capture the tag name of an element,
  -- attribute name,
  -- and attribute value
  local query = vim.treesitter.query.parse_query(
    "html",
    [[
      ([(start_tag (tag_name) @tag_name) (self_closing_tag (tag_name) @tag_name)]) 
      (attribute (attribute_name) @attr_name (#eq? @attr_name "class") (quoted_attribute_value) @attr_value)
    ]]
  )

  -- find the node at current cursor position
  local node = vim.treesitter.get_node_at_pos(0, row - 1, col)

  if not node then
    return
  end

  local tag_name_row = 0
  local tag_name_end_col = 0
  local has_class_attr = false

  for id, capture, _ in query:iter_captures(node:root(), bufnr, row - 1, row) do
    local tag_name = query.captures[1]
    local _attr_name = query.captures[2]
    local attr_value = query.captures[3]

    local name = query.captures[id]

    local _, _, _, end_col = capture:range()

    -- Store tag name position for future use
    if name == tag_name then
      tag_name_row = end_row
      tag_name_end_col = end_col
    end

    -- If attribute values already exist,
    -- then add a space at the end and change to insert mode
    if name == attr_value then
      vim.api.nvim_win_set_cursor(0, { row, end_col - 1 })
      vim.cmd("startinsert")
      vim.api.nvim_feedkeys(" ", "n", false)
      has_class_attr = true
    end
  end

  -- If there is no attribute values,
  -- Inject [[class=""]]
  if not has_class_attr and tag_name_row ~= 0 then
    local inject_str = [[ class=""]]
    local line = vim.api.nvim_get_current_line()
    local new_line = line:sub(0, tag_name_end_col)
      .. inject_str
      .. line:sub(tag_name_end_col + 1)
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(
      0,
      { row, tag_name_end_col + string.len(inject_str) - 1 }
    )
    vim.cmd("startinsert")
  end
end

M.inject_class()

return M
