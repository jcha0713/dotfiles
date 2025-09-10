local M = {}

local commit_progress_key
local filepath = vim.fn.expand("%:p")
local Component = require("modules.ui.base")

--- show progress notification with fidget
---@param title string
---@param msg string?
---@return string key for the notification
local function claude_progress(title, msg)
  local message = msg or "working..."
  local key = "claude_commit_" .. os.time()

  require("fidget").notify(message, vim.log.levels.INFO, {
    annote = title,
    key = key,
  })

  return key
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
---@param claude_result vim.SystemCompleted
local function handle_exit(claude_result)
  -- Finish the progress notification
  if commit_progress_key then
    require("fidget").notify(nil, nil, { key = commit_progress_key })
    commit_progress_key = nil
  end

  if claude_result.code == 1 then
    vim.print(claude_result.stderr)
  end
  if claude_result.code == 0 then
    local commit_msg = claude_result.stdout:gsub("^%s*", ""):gsub("%s*$", "")
    local success_msg = "Changes committed successfully!"

    vim.schedule(function()
      local commit_msg_tbl = {}

      -- Split by lines but preserve empty lines for proper spacing
      for line in (commit_msg .. "\n"):gmatch("([^\n]*)\n") do
        table.insert(commit_msg_tbl, line)
      end

      local popup = Component(nil, {
        label = {
          top = " Generated Commit Message",
        },
        default_text = commit_msg_tbl,
        on_submit = function(final_commit_msg)
          run_command({
            "sh",
            "-c",
            string.format("git commit -m '%s'", final_commit_msg),
          }, success_msg)
        end,
        on_abort = function()
          vim.notify("Commit aborted by user", vim.log.levels.INFO, {})
        end,
      })
      popup:mount()
    end)
  end
end

--- generate AI commit messages using Claude Code
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
      "git diff --staged %s '%s' | claude -p 'You are a git commit message generator. Output ONLY the raw commit message text, nothing else. No explanations, no markdown, no prefixes. Format: concise summary under 80 characters. IMPORTANT: Do not use bullet points unless for complex code changes.' --output-format text",
      diff_prefix,
      filepath
    )

    commit_progress_key = claude_progress("Claude", "writing commit msg")
    run_command({ "sh", "-c", diff_cmd }, nil, handle_exit)
  end
end

function M.do_empty_commit()
  local popup = Component(nil, {
    label = {
      top = " Commit Message",
    },
    on_submit = function(new_commit_msg)
      run_command({
        "sh",
        "-c",
        string.format("git commit --allow-empty -m 'TODO: %s'", new_commit_msg),
      }, "Successfully committed empty commit!")
    end,
    on_abort = function()
      vim.notify("Commit aborted by user", vim.log.levels.INFO, {})
    end,
  })

  popup:mount()
end

return M
