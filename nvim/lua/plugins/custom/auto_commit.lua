local M = {}

local commit_progress
local filepath = vim.fn.expand("%:p")

local function sgpt_progress(title, msg)
  return require("fidget.progress").handle.create({
    title = title,
    message = msg,
    lsp_client = { name = "AI" },
    percentage = nil,
  })
end

--- run shell commands
---@param cmd string[]
---@param success_msg string | nil
---@param on_exit function | nil
---@return vim.SystemCompleted | vim.SystemObj
local function run_command(cmd, success_msg, on_exit)
  if on_exit then
    return vim.system(cmd, { text = true }, on_exit)
  end

  local command = vim.system(cmd, { text = true }):wait()

  if command.code == 0 then
    success_msg = success_msg or "Command executed successfully"
    vim.notify(success_msg, vim.log.levels.INFO)
  else
    vim.notify(command.stderr, vim.log.levels.ERROR)
  end

  return command
end

--- commit changes to git with AI generated message
---@param sgpt_result vim.SystemCompleted
local function handle_exit(sgpt_result)
  commit_progress:finish()
  if sgpt_result.code == 1 then
    vim.print(sgpt_result.stderr)
  end
  if sgpt_result.code == 0 then
    local commit_msg = sgpt_result.stdout:gsub("^%s*(.-)%s*$", "%1")
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
        vim.ui.input({
          prompt = "Edit commit message",
          default = commit_msg,
        }, function(new_commit_msg)
          if new_commit_msg == nil then
            vim.notify("Commit aborted by user", vim.log.levels.WARN, {})
          end

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
        end)
      end
    end)
  end
end

--- generate AI commit messages using shell-gpt
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

    local diff_prefix = is_untracked and "--no-index -- /dev/null" or "HEAD"

    local diff_cmd = string.format(
      "git diff --staged %s '%s' | sgpt 'Create a git commit message that begins with a main summary, capturing the essence of the changes in under 80 characters, followed by a detailed enumeration of all modifications in bullet points. This should encompass specific alterations, bug fixes, enhancements, or optimizations, detailing what was changed and why. No further explanation or description is required; only the commit message is to be returned.'",
      diff_prefix,
      filepath
    )

    commit_progress = sgpt_progress("AI", "writing commit msg")
    run_command({ "sh", "-c", diff_cmd }, nil, handle_exit)
  end
end

return M
