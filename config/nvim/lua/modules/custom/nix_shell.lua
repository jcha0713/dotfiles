local M = {}

vim.api.nvim_create_user_command("RunWithDeno", function(opts)
  local bufnr = vim.api.nvim_get_current_buf()

  local lines =
    vim.api.nvim_buf_get_lines(bufnr, opts.line1 - 1, opts.line2, false)
  local code = table.concat(lines, "\n")

  local extension = ".ts"
  local temp_file = "/tmp/nvim_deno_" .. os.time() .. extension

  local file = io.open(temp_file, "w")
  if file == nil then
    return
  end
  file:write(code)
  file:close()

  -- Execute with nix-shell and deno
  local cmd = string.format(
    'nix-shell -p deno --run "deno run --allow-all %s"',
    temp_file
  )
  local handle = io.popen(cmd .. " 2>&1")

  if handle == nil then
    return
  end

  local result = handle:read("*a")
  handle:close()

  -- Clean up
  os.remove(temp_file)

  -- Show result in floating window
  local buf = vim.api.nvim_create_buf(false, true)
  local lines_output = vim.split(result, "\n")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines_output)

  -- Create floating window
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(#lines_output + 2, vim.o.lines - 6)
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = (vim.o.lines - height) / 2,
    col = (vim.o.columns - width) / 2,
    style = "minimal",
    border = "rounded",
    title = " Deno Output ",
    title_pos = "center",
  }

  vim.api.nvim_open_win(buf, true, opts)
  vim.bo[buf].filetype = "javascript"
  vim.bo[buf].buftype = "nofile"

  -- Close on escape or q
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf })
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
end, { range = true })

M.setup = function()
  vim.keymap.set(
    "v",
    "<leader>rd",
    ":RunWithDeno<CR>",
    { desc = "Run JS/TS with Deno" }
  )
end

return M
