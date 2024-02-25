local M = {}

local filename = vim.fn.expand("%:p")

local function handle_exit(sgpt_result)
  if sgpt_result.code == 1 then
    vim.print(sgpt_result.stderr)
  end
  if sgpt_result.code == 0 then
    vim.schedule(function()
      local confirm = vim.fn.confirm(
        "Generated Message:\n================\n"
          .. sgpt_result.stdout
          .. "\n================\nCommit with this message?",
        "&Yes\n&Edit\n&Cancel"
      )
      if confirm == 1 then
        vim
          .system({
            "sh",
            "-c",
            string.format(
              "git add '%s' && git commit -m '%s'",
              filename,
              sgpt_result.stdout
            ),
          })
          :wait()
      elseif confirm == 2 then
        vim.ui.input(
          { prompt = "Edit commit message", default = sgpt_result.stdout },
          function(input)
            if input then
              local commit_cmd = vim
                .system({
                  "sh",
                  "-c",
                  string.format(
                    "git add '%s' && git commit -m '%s'",
                    filename,
                    input
                  ),
                })
                :wait()

              if commit_cmd.code == 0 then
                vim.notify("Successfully commited!", vim.log.levels.INFO, {})
              end
            end
          end
        )
      end
    end)
  end
end

function M.generate_commit_message()
  if type(filename) ~= "string" then
    return
  end

  local untracked_files_cmd =
    { "git", "ls-files", "--others", "--exclude-standard" }
  local untracked_files_output =
    vim.system(untracked_files_cmd, { text = true }):wait()

  if untracked_files_output.code == 0 then
    local is_untracked = string.find(
      untracked_files_output.stdout,
      vim.fn.fnamemodify(filename, ":t")
    )
    local diff_cmd
    if is_untracked then
      diff_cmd = string.format(
        "git diff --no-index -- /dev/null '%s' | sgpt 'Write a concise git commit message in under 80 characters for me'",
        filename
      )
    else
      diff_cmd = string.format(
        "git diff HEAD -- '%s' | sgpt 'Write a concise git commit message in under 80 characters for me'",
        filename
      )
    end

    vim.system({
      "sh",
      "-c",
      diff_cmd,
    }, { text = true }, handle_exit)
  end
end

return M
