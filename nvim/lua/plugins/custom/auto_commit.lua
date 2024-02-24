local M = {}

local function handle_exit(obj)
  if obj.code == 1 then
    vim.print(obj.stderr)
  end
  if obj.code == 0 then
    vim.schedule(function()
      -- TODO: implement EDIT
      local confirm =
        vim.fn.confirm("Commit with generated message?", "&Yes\n&Edit\n&Cancel")
      if confirm == 1 then
        vim.print(obj.stdout)
      end
    end)
  end
end

function M.generate_commit_message()
  local filename = vim.fn.expand("%:p")

  if type(filename) ~= "string" then
    return
  end

  -- TODO: handle untracked files
  local cmd = {
    "sh",
    "-c",
    string.format(
      "git diff -- '%s' | sgpt 'Summarize git diff changes for a commit message in under 80 chars'",
      filename
    ),
  }

  vim.system(cmd, { text = true }, handle_exit)
end

return M
