-- idg.lua: Intention-Driven Git Integration for Neovim
local M = {}

local has_sqlite, sqlite = pcall(require, "sqlite")

if not has_sqlite then
  error(
    "IDG requires sqlite.lua (https://github.com/kkharji/sqlite.lua) "
      .. tostring(sqlite)
  )
end

-- SQLite database connection for storing and managing TODOs
local sqlite_db = require("sqlite.db")
local tbl = require("sqlite.tbl")
local db_path = vim.fn.stdpath("data") .. "/idg.db"
local strftime = sqlite_db.lib.strftime

-- nui-components for rendering ui
local n = require("nui-components")

-- Table schema
---@class Todos
---@field id number: unique identifier
---@field commit_hash string: commit hash
---@field message string: commit message
---@field created_at number: timestamp of creation
---@field completed_at number: timestamp of completion
---@field repository string: path to repository
---@field branch string: current branch

---@class Fixups
---@field id number: unique identifier
---@field commit_hash string: commit hash
---@field message string: commit message
---@field created_at number: timestamp of creation
---@field todo_id number: id of associated todo

-- Database
---@class TodoTbl: sqlite_tbl
---@class FixupTbl: sqlite_tbl

---@class IDGDB: sqlite_db
---@field todos TodoTbl
---@field fixups FixupTbl

-- Store database connection at module level
M.db = nil

-- Lazy database initialization
local function get_db()
  -- Return existing connection if we have one
  if M.db and M.db:isopen() then
    return M.db
  end

  -- Initialize database connection
  M.db = sqlite_db:extend({
    uri = db_path,
    opts = { keep_open = true },
    todos = {
      id = true,
      commit_hash = { type = "text", required = true },
      message = { type = "text" },
      created_at = { type = "date", default = strftime("%s", "now") },
      completed_at = { type = "date" },
      repository = { type = "text" },
      branch = { type = "text" },
      ensure = true,
    },
    fixups = {
      id = true,
      commit_hash = { type = "text", required = true },
      description = { type = "text" },
      created_at = { type = "date", default = strftime("%s", "now") },
      todo = {
        type = "integer",
        reference = "todos.id",
        on_delete = "cascade",
      },
      ensure = true,
    },
  })

  -- Verify database is working
  if not M.db:exists("todos") then
    error("Failed to initialize database")
  end

  return M.db
end

-- Cleanup function to close database connection
local function cleanup()
  if M.db and M.db:isopen() then
    M.db:close()
    M.db = nil
  end
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

M.create_todo = function()
  local db = get_db()

  local renderer = n.create_renderer({
    width = 60,
    height = 10,
  })

  local signal = n.create_signal({
    new_commit_msg = "",
  })

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

          db:insert("todos", {
            commit_hash = vim.fn.system("git rev-parse HEAD"):gsub("\n", ""),
            message = [[TODO: ]] .. new_commit_msg,
            repository = vim.fn.getcwd(),
            branch = vim.fn.system("git branch --show-current"):gsub("\n", ""),
          })

          renderer:close()
        end,
      },
      n.text_input({
        autofocus = true,
        autoresize = true,
        size = 5,
        border_label = " Commit Message",
        placeholder = "Define your next goal here",
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
  local db = get_db()
  local todos = db:select("todos", { where = { completed_at == nil } })

  local signal = n.create_signal({
    selected = nil,
    description = "",
  })

  local renderer = n.create_renderer({
    width = 100,
    height = 10,
  })

  local todos_to_data = function(todos)
    if not todos then
      return {}
    end

    if type(todos) ~= "table" then
      return {}
    end

    local data = {}

    for _, todo in ipairs(todos) do
      local goal = todo.message:match("^TODO:%s*(.+)$")

      if goal then
        local option =
          n.option(string.sub(todo.commit_hash, 1, 7) .. [[ - ]] .. goal, {
            id = todo.commit_hash,
          })

        table.insert(data, option)
      end
    end

    return data
  end

  local fixup_input = function()
    local to_macos_keys = require("modules.utils").to_macos_keys

    vim.api.nvim_set_hl(
      0,
      "NuiComponentsSelectOptionSelected",
      { fg = "#ee90a2" }
    )

    return n.form(
      {
        id = "fixup",
        submit_key = "<D-CR>",
        on_submit = function()
          local selected_commit = signal.selected:get_value()
          local description = signal.description:get_value()

          run_command({
            "sh",
            "-c",
            string.format("git commit --fixup '%s'", selected_commit.id),
          }, "Successfully committed fixup commit!")

          db:insert("fixups", {
            commit_hash = vim.fn.system("git rev-parse HEAD"):gsub("\n", ""),
            description = description,
            created_at = strftime("%s", "now"),
            todo = selected_commit.id,
          })

          renderer:close()
        end,
      },
      n.select({
        autofocus = true,
        border_label = " Fixup",
        selected = signal.selected,
        is_focusable = true,
        data = todos_to_data(todos),
        multiselect = false,
        on_select = function(nodes)
          local selected = signal.selected:get_value()

          if selected == nil or nodes.id ~= selected.id then
            signal.selected = nodes
          else
            signal.selected = nil
          end
        end,
        on_unmont = function()
          signal.selected = nil
        end,
      }),
      n.text_input({
        autoresize = true,
        is_focusable = true,
        size = 1,
        border_label = "Description",
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

function M.setup(opts)
  opts = opts or {}

  -- Register cleanup when Neovim exits
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = cleanup,
  })

  -- Register commands
  vim.api.nvim_create_user_command("IDGTodo", M.create_todo, {})
  vim.api.nvim_create_user_command("IDGFixup", M.create_fixup, {})
end

return M
