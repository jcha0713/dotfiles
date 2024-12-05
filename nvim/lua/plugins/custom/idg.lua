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
      message = { type = "text" },
      created_at = { type = "date", default = strftime("%s", "now") },
      todo_id = { type = "number", reference = "todos.id" },
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
  local Component = require("modules.ui.base")

  local popup = Component(nil, {
    label = {
      top = " Commit Message",
    },
    on_submit = function(new_commit_msg)
      run_command({
        "sh",
        "-c",
        string.format("git commit --allow-empty -m 'TODO: %s'", new_commit_msg),
      }, "Successfully committed empty commit!")

      db:insert("todos", {
        commit_hash = vim.fn.system("git rev-parse HEAD"):gsub("\n", ""),
        message = [[TODO: ]] .. new_commit_msg,
        repository = vim.fn.getcwd(),
        branch = vim.fn.system("git branch --show-current"):gsub("\n", ""),
      })
    end,
    on_abort = function()
      vim.notify("Commit aborted by user", vim.log.levels.INFO, {})
    end,
  })

  popup:mount()
end

M.create_fixup = function()
  local db = get_db()
  local todos = db:select("todos", { where = { completed_at == nil } })

  print(vim.inspect(todos))
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
