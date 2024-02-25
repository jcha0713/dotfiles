local M = {}

local filepath = vim.fn.expand("%:p")

local function run_command(cmd, success_msg, on_exit)
  success_msg = success_msg or "Command executed successfully"

  if on_exit then
    return vim.system(cmd, { text = true }, on_exit)
  end

  local command = vim.system(cmd, { text = true }):wait()

  if command.code == 0 then
    vim.notify(success_msg, vim.log.levels.INFO)
  else
    vim.notify(command.stderr, vim.log.levels.ERROR)
  end

  return command
end

local function handle_exit(sgpt_result)
  if sgpt_result.code == 1 then
    vim.print(sgpt_result.stderr)
  end
  if sgpt_result.code == 0 then
    local commit_msg = sgpt_result.stdout
    local success_msg = "Changes committed successfully!"
    vim.schedule(function()
      local confirm = vim.fn.confirm(
        "Generated Message:\n================\n"
          .. commit_msg
          .. "\n================\nCommit with this message?",
        "&Yes\n&Edit\n&Cancel"
      )
      if confirm == 1 then
        run_command({
          "sh",
          "-c",
          string.format(
            "git add '%s' && git commit -m '%s'",
            filepath,
            commit_msg
          ),
        }, success_msg)
      elseif confirm == 2 then
        vim.ui.input(
          { prompt = "Edit commit message", default = commit_msg },
          function(new_commit_msg)
            if new_commit_msg then
              run_command({
                "sh",
                "-c",
                string.format(
                  "git add '%s' && git commit -m '%s'",
                  filepath,
                  new_commit_msg
                ),
              }, success_msg)
            end
          end
        )
      end
    end)
  end
end

function M.generate_commit_message()
  if type(filepath) ~= "string" then
    return
  end

  local untracked_files_cmd =
    { "git", "ls-files", "--others", "--exclude-standard" }
  local untracked_files_output = run_command(untracked_files_cmd)

  if untracked_files_output.code == 0 then
    local is_untracked = string.find(
      untracked_files_output.stdout,
      vim.fn.fnamemodify(filepath, ":t")
    )
    local diff_cmd
    if is_untracked then
      diff_cmd = string.format(
        "git diff --no-index -- /dev/null '%s' | sgpt 'Write a concise git commit message in under 80 characters for me'",
        filepath
      )
    else
      diff_cmd = string.format(
        "git diff HEAD -- '%s' | sgpt 'Write a concise git commit message in under 80 characters for me'",
        filepath
      )
    end

    run_command({ "sh", "-c", diff_cmd }, nil, handle_exit)
  end
end

return M
