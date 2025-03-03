-- idg.lua: Intention-Driven Git Integration for Neovim

-- TODO: search through todo comments and display them when creating a new todo

local M = {}

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

---@class Commit
---@field commit_hash string
---@field message string
---@field body string

---@param grep_pattern string
---@return Commit[]
local fetch_commits = function(grep_pattern)
  local commits = {}

  if vim.fn.finddir(".git") == "" then
    return {}
  end

  local result = run_command({
    "sh",
    "-c",
    string.format(
      "git log --grep='%s' --format='%%H %%s|||%%b' --reverse",
      grep_pattern
    ),
  }, "TODO commits fetched!")

  if result.code ~= 0 then
    vim.notify(result.stderr, vim.log.levels.ERROR)
    return {}
  end

  for line in result.stdout:gmatch("[^\r\n]+") do
    local commit_hash, message, body = line:match("(%w+)%s+(.*)|||(.*)")
    if commit_hash and message then
      table.insert(commits, {
        commit_hash = commit_hash,
        message = message,
        body = body,
      })
    end
  end

  return commits
end

local fetch_fixups = function()
  return fetch_commits("^fixup!")
end

local fetch_todos = function()
  return fetch_commits("^TODO:")
end

-- nui-components for rendering ui
local n = require("nui-components")

M.create_todo_with_comment = function(opts)
  local todo_line =
    vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
  local todo_content = todo_line[1]:match("TODO:%s*(.+)")

  if todo_content == "" then
    todo_content = nil
  end

  M.create_todo(todo_content)
end

M.create_todo = function(todo_content)
  local renderer = n.create_renderer({
    width = 60,
    height = 20,
  })

  local signal = n.create_signal({
    new_commit_msg = "",
  })

  if todo_content ~= nil and type(todo_content) == "string" then
    signal.new_commit_msg = todo_content
  else
    signal.new_commit_msg = ""
  end

  local commit_input = function()
    local to_macos_keys = require("modules.utils").to_macos_keys

    return n.form(
      {
        id = "form",
        submit_key = "<D-CR>",
        on_submit = function()
          local new_commit_msg = signal.new_commit_msg:get_value()

          run_command({
            "sh",
            "-c",
            string.format(
              "git commit --allow-empty -m 'TODO: %s'",
              new_commit_msg
            ),
          }, "Successfully committed empty commit!")

          renderer:close()
          require("modules.custom.winbar").update_winbar()
        end,
      },
      n.text_input({
        autofocus = true,
        autoresize = true,
        size = 3,
        border_label = " Commit Message",
        placeholder = "Define your next goal here",
        value = signal.new_commit_msg,
        hidden = signal.selected:map(function(value)
          return value ~= nil
        end),
        on_change = function(value, _component)
          signal.new_commit_msg = value
        end,
        on_mount = function(component)
          component:set_border_text(
            "bottom",
            " (" .. to_macos_keys("D CR") .. ")" .. " Submit ",
            "right"
          )
        end,
      })
    )
  end

  renderer:render(commit_input)
end

M.create_fixup = function()
  local signal = n.create_signal({
    selected = nil,
    original_message = "",
    description = "",
    is_todo = false,
  })

  local renderer = n.create_renderer({
    width = 100,
    height = 10,
  })

  local todos_to_data = function()
    local todos = fetch_todos()

    local data = {}

    for _, todo in ipairs(todos) do
      local option = n.option(
        string.sub(todo.commit_hash, 1, 7) .. [[ - ]] .. todo.message,
        {
          id = todo.commit_hash,
          message = todo.message,
          body = todo.body,
        }
      )

      table.insert(data, option)
    end

    return data
  end

  local fixup_input = function()
    local to_macos_keys = require("modules.utils").to_macos_keys

    return n.form(
      {
        id = "fixup",
        submit_key = "<D-CR>",
        on_submit = function()
          local original_message = signal.original_message:get_value()
          local description = signal.description:get_value()

          local selected = signal.selected:get_value()

          if selected == nil then
            vim.notify("Please select a fixup commit!", vim.log.levels.ERROR)
            return
          end

          run_command({
            "sh",
            "-c",
            string.format(
              "git commit -m 'fixup! %s' -m '%s'",
              original_message,
              description
            ),
          }, "Successfully committed fixup commit!")

          renderer:close()
        end,
      },
      n.select({
        autofocus = true,
        border_label = " Fixup",
        selected = signal.selected,
        flex = 1,
        is_focusable = true,
        data = todos_to_data(),
        multiselect = false,
        on_select = function(nodes)
          local selected = signal.selected:get_value()

          if selected == nil or nodes.id ~= selected.id then
            signal.selected = nodes
            signal.original_message = nodes.message
          else
            signal.selected = nil
            signal.original_message = nodes.message
          end
        end,
        on_unmount = function()
          signal.selected = nil
        end,
      }),
      n.text_input({
        autoresize = true,
        is_focusable = true,
        flex = 1,
        border_label = "Additional message",
        on_change = function(value, _component)
          signal.description = value
        end,
        on_mount = function(component)
          component:set_border_text(
            "bottom",
            " (" .. to_macos_keys("D CR") .. ")" .. " Submit ",
            "right"
          )
        end,
      })
    )
  end

  renderer:render(fixup_input)
end

M.squash = function()
  local signal = n.create_signal({
    selected = nil,
  })

  local renderer = n.create_renderer({
    width = 100,
    height = 10,
  })

  local todos_to_data = function()
    local todos = fetch_todos()

    local data = {}

    for _, todo in ipairs(todos) do
      -- TODO: display number of fixups
      local option = n.option(
        string.sub(todo.commit_hash, 1, 7) .. [[ - ]] .. todo.message,
        {
          id = todo.commit_hash,
          message = todo.message,
          body = todo.body,
        }
      )

      table.insert(data, option)
    end

    return data
  end

  local squash_input = function()
    local to_macos_keys = require("modules.utils").to_macos_keys

    vim.api.nvim_set_hl(
      0,
      "NuiComponentsSelectOptionSelected",
      { fg = "#ee90a2" }
    )

    return n.form(
      {
        id = "squash",
        submit_key = "<D-CR>",
        on_submit = function()
          local selected = signal.selected:get_value()

          if selected == nil then
            vim.notify("Please select a target commit!", vim.log.levels.ERROR)
            return
          end

          local function rebase(popup)
            local cli_args = popup:get_arguments()
            require("neogit.lib.git.rebase").rebase_interactive(
              popup.state.env.commit_hash .. "^",
              cli_args
            )
          end

          local function open_rebase_popup()
            local popup = require("neogit.lib.popup")
            local p = popup
              .builder()
              :name("IDG Squash")
              :switch("s", "autosquash", "Autosquash", {
                enabled = true,
              })
              :switch("S", "autostash", "Autostash", {
                enabled = true,
              })
              :option(
                "x",
                "exec",
                string.format(
                  "git commit --amend -m \"$(git log --format=%%B -n1 | sed 's/TODO: //')\""
                ),
                "Remove TODO prefix from commit message",
                {
                  key_prefix = "-",
                  separator = " ",
                  enabled = true,
                }
              )
              :action("r", "Rebase", rebase)
              :env({
                commit_hash = selected.id,
              })
              :build()

            p:show()

            return p
          end

          open_rebase_popup()

          renderer:close()
        end,
      },
      n.select({
        autofocus = true,
        border_label = " Squash",
        selected = signal.selected,
        flex = 1,
        is_focusable = true,
        data = todos_to_data(),
        multiselect = false,
        on_select = function(nodes)
          local selected = signal.selected:get_value()

          if selected == nil or nodes.id ~= selected.id then
            signal.selected = nodes
          else
            signal.selected = nil
          end
        end,
        on_mount = function(component)
          component:set_border_text(
            "bottom",
            " (" .. to_macos_keys("D CR") .. ")" .. " Submit ",
            "right"
          )
        end,
        on_unmount = function()
          signal.selected = nil
        end,
      })
    )
  end

  renderer:render(squash_input)
end

M.get_last_todo = function()
  local todos = fetch_todos()

  if #todos == 0 then
    return nil
  end

  return todos[#todos]
end

function M.setup(opts)
  opts = opts or {}

  vim.api.nvim_create_user_command("IDGTodo", M.create_todo, {})
  vim.api.nvim_create_user_command("IDGFixup", M.create_fixup, {})
  vim.api.nvim_create_user_command("IDGSquash", M.squash, {})
  vim.api.nvim_create_user_command(
    "IDGTodoComment",
    M.create_todo_with_comment,
    { range = "%" }
  )
end

return M
