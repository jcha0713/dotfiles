local M = {}

M.add_title_to_url = function()
  -- Get the current WORD under the cursor: sequence of non-blank characters
  local url = vim.fn.expand("<cWORD>")

  -- Verify that the word is a URL
  if not url:match("^http") then
    print("cursor is not on a url: " .. url)
    return
  end

  -- Get the position of the URL in the buffer.
  -- The row will be the row the cursor is currently on...
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  -- ...and we can match the string to find the start and end columns.
  local start_col, end_col =
    string.find(vim.api.nvim_get_current_line(), vim.pesc(url))

  -- Technically, these could be nil, so check first.
  if start_col and end_col then
    -- Get the page title using the shell script, and replace any newlines.
    local result = vim
      .system({
        "sh",
        "-c",
        string.format("$HOME/.config/nvim/utils/fetch-title.sh '%s'", url),
      }, { text = true })
      :wait()

    local title = result.stdout:gsub("[\n\r]", "")

    -- Format the title and URL for Markdown.
    local markdown_link = ("[%s](%s)"):format(title, url)

    -- Replace the URL in the buffer with the formatted link, and work around the
    -- fact that Lua is one-based
    vim.api.nvim_buf_set_text(
      0,
      row - 1,
      start_col - 1,
      row - 1,
      end_col,
      { markdown_link }
    )
  end
end

M.setup = function()
  vim.keymap.set(
    "n",
    "<leader>uu",
    M.add_title_to_url,
    { desc = "fetch title from url" }
  )
end

return M
