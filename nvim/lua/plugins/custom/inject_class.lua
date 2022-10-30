-- TODO: Refactor inject_class function
-- TODO: Add remove_class that removes class attribute
-- TEST: Test with js, jsx, astro ...

local M = {}

local get_node_text = function(node)
  return vim.treesitter.query.get_node_text(node, 0)
end

M.inject_class = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local cursor_row, cursor_col = unpack(cursor_pos)
  local lang = vim.api.nvim_buf_get_option(bufnr, "ft")

  -- treesitter query to capture the tag name of an element,
  -- attribute name,
  -- and attribute value
  local query = M.get_query(lang)

  -- find the node at current cursor position
  local node = vim.treesitter.get_node_at_pos(0, cursor_row - 1, cursor_col, {})

  if not node then
    error("No Treesitter parser found.")
    return
  end

  while node:type() ~= "element" do
    if node:parent() == nil then
      return
    end
    node = node:parent()
  end

  local element_row_start, element_col_start, element_row_end, element_col_end =
    node:range()
  local has_class_attr = false
  local tag_name_row = 0
  local tag_name_end_col = 0

  for id, capture, _ in query:iter_captures(node, bufnr, cursor_row - 1, cursor_row) do
    local tag_name = query.captures[1]
    local attr_name = query.captures[2]
    local attr_value = query.captures[3]

    local name = query.captures[id]

    local capture_start_row, capture_start_col, capture_end_row, capture_end_col =
      capture:range()

    -- Store tag name position for future use
    if name == tag_name then
      tag_name_row = capture_end_row
      tag_name_end_col = capture_end_col
    end

    if name == attr_value then
      has_class_attr = true

      local has_value = string.len(vim.treesitter.get_node_text(capture, bufnr))
        > 2

      local inject_str = has_value and " " or ""
      capture_end_col = has_value and capture_end_col or capture_end_col - 1

      local line = vim.api.nvim_buf_get_lines(
        bufnr,
        capture_start_row,
        capture_end_row + 1,
        false
      )

      local new_line = M.replace_line(line[1], capture_end_col - 1, inject_str)

      vim.api.nvim_buf_set_lines(
        bufnr,
        capture_start_row,
        capture_end_row + 1,
        false,
        { new_line }
      )

      vim.api.nvim_win_set_cursor(0, { capture_end_row + 1, capture_end_col })

      vim.cmd("startinsert")
    end
  end

  if not has_class_attr and tag_name_row ~= 0 then
    local inject_str = [[ class=""]]

    local line = vim.api.nvim_buf_get_lines(
      bufnr,
      tag_name_row,
      tag_name_row + 1,
      false
    )

    local new_line = M.replace_line(line[1], tag_name_end_col, inject_str)

    vim.api.nvim_buf_set_lines(
      bufnr,
      tag_name_row,
      tag_name_row + 1,
      false,
      { new_line }
    )

    vim.api.nvim_win_set_cursor(
      0,
      { tag_name_row + 1, tag_name_end_col + string.len(inject_str) - 1 }
    )

    vim.cmd("startinsert")
  end
end

M.replace_line = function(line, replace_col, insert_str)
  local new_line = line:sub(0, replace_col)
    .. insert_str
    .. line:sub(replace_col + 1)
  return new_line
end

M.get_query = function(lang)
  local queryText = lang == "html"
      and [[
      (element [(start_tag (tag_name) @tag_name) (self_closing_tag (tag_name) @tag_name)])
      (element (_ (attribute (attribute_name) @attr_name (#eq? @attr_name "class") (quoted_attribute_value) @attr_value)))
    ]]
    or [[
      [(jsx_opening_element (identifier) @tag_name) (jsx_self_closing_element (identifier) @tag_name)]
      (jsx_element (_ (jsx_attribute (property_identifier) @attr_name (#eq? @attr_name "className") (string) @attr_value)))
    ]]
  local query = vim.treesitter.query.parse_query(lang, queryText)

  return query
end

M.inject_class()

return M
