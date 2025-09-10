local M = {}

local filepath = vim.fn.expand("%:p")
local Component = require("modules.ui.base")

--- show progress notification
---@param title string
---@param msg string?
local function claude_progress(title, msg)
  local message = title .. (msg and (": " .. msg) or "")
  vim.notify(message, vim.log.levels.INFO)
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
  if claude_result.code == 1 then
    vim.print(claude_result.stderr)
  end
  if claude_result.code == 0 then
    local commit_msg = claude_result.stdout:gsub("^%s*(.-)%s*$", "%1")
    local success_msg = "Changes committed successfully!"

    vim.schedule(function()
      local commit_msg_tbl = {}

      for line in commit_msg:gmatch("[^\n]+") do
        local trimmed_line = vim.trim(line)
        table.insert(commit_msg_tbl, trimmed_line)
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
      "git diff --staged %s '%s' | claude -p 'You are a git commit message generator. Output ONLY the raw commit message text, nothing else. No explanations, no markdown, no prefixes like \"Based on\" or \"Here is\". Format: concise summary under 80 characters. Use bullet points sparingly - only add them when the main message truly needs extra details for clarity. Most commits should be just the main message. When adding bullet points, include a blank newline between the main message and description. Example output: \"fix: resolve authentication bug\" or \"add: user profile feature\\n\\n- implement avatar upload\\n- add profile validation\"' --output-format text",
      diff_prefix,
      filepath
    )

    claude_progress("Claude", "writing commit msg")
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
