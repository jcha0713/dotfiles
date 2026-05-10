local M = {}

local temp_paths = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.ERROR, { title = "DiffTool" })
end

local run = require("neuvim.modules.job").run

local function current_dir()
  local buf_dir = vim.fn.expand("%:p:h")
  if buf_dir ~= "" and vim.fn.isdirectory(buf_dir) == 1 then
    return buf_dir
  end

  if vim.uv and vim.uv.cwd then
    local ok, cwd = pcall(vim.uv.cwd)
    if ok and cwd and cwd ~= "" then
      return cwd
    end
  end

  local ok, cwd = pcall(vim.fn.getcwd)
  if ok and cwd and cwd ~= "" then
    return cwd
  end

  notify("could not determine current working directory")
  return nil
end

local function git_root()
  local cwd = current_dir()
  if not cwd then
    return nil
  end

  local out, err = run({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })
  if not out then
    notify(err)
    return nil
  end

  return vim.trim(out)
end

local function temp_dir(prefix)
  local path = vim.fn.tempname() .. "-" .. prefix
  vim.fn.mkdir(path, "p")
  table.insert(temp_paths, path)
  return path
end

local function temp_file(prefix)
  local path = vim.fn.tempname() .. "-" .. prefix
  table.insert(temp_paths, path)
  return path
end

local function archive_ref(root, source)
  local dir = temp_dir("difftool-" .. source:gsub("[^%w._-]", "_"))
  local tar = temp_file("difftool.tar")

  local _, archive_err = run({
    "git",
    "-C",
    root,
    "archive",
    "--format=tar",
    "--output=" .. tar,
    source,
  })
  if archive_err then
    notify(("not a path or git tree: %s"):format(source))
    return nil
  end

  local _, tar_err = run({ "tar", "-xf", tar, "-C", dir })
  if tar_err then
    notify(tar_err)
    return nil
  end

  return dir
end

local function snapshot_worktree(root)
  local dir = temp_dir("difftool-worktree")
  local out, err = run({
    "git",
    "-C",
    root,
    "ls-files",
    "-z",
    "--cached",
    "--others",
    "--exclude-standard",
  }, { text = false })
  if not out then
    notify(err)
    return nil
  end

  for rel in out:gmatch("([^%z]+)") do
    local src = vim.fs.joinpath(root, rel)
    if vim.fn.filereadable(src) == 1 then
      local dst = vim.fs.joinpath(dir, rel)
      vim.fn.mkdir(vim.fs.dirname(dst), "p")
      local ok, copy_err = vim.uv.fs_copyfile(src, dst)
      if not ok then
        notify(("copy failed for %s: %s"):format(rel, copy_err))
        return nil
      end
    end
  end

  return dir
end

local function resolve_source(root, source)
  source = vim.trim(source)
  if source == "" then
    return nil
  end

  local expanded = vim.fn.expand(source)
  if
    vim.fn.filereadable(expanded) == 1 or vim.fn.isdirectory(expanded) == 1
  then
    return vim.fs.normalize(expanded)
  end

  return archive_ref(root, source)
end

local function upstream_ref(root)
  local upstream =
    run({ "git", "-C", root, "rev-parse", "--abbrev-ref", "@{u}" })
  if upstream then
    return vim.trim(upstream)
  end

  local origin_head =
    run({ "git", "-C", root, "rev-parse", "--verify", "origin/HEAD" })
  if origin_head then
    return "origin/HEAD"
  end

  notify("no upstream branch or origin/HEAD found")
  return nil
end

function M.open(left, right, opt)
  require("difftool").open(
    left,
    right,
    vim.tbl_deep_extend("force", {
      ignore = { ".git", ".DS_Store", "result" },
      rename = { detect = true },
    }, opt or {})
  )
end

function M.local_changes()
  local root = git_root()
  if not root then
    return
  end

  local left = archive_ref(root, "HEAD")
  local right = snapshot_worktree(root)
  if left and right then
    M.open(left, right)
  end
end

function M.upstream_changes()
  local root = git_root()
  if not root then
    return
  end

  local upstream = upstream_ref(root)
  if not upstream then
    return
  end

  local left = archive_ref(root, upstream)
  local right = snapshot_worktree(root)
  if left and right then
    M.open(left, right)
  end
end

function M.sources(left, right)
  local root = git_root()
  if not root then
    return
  end

  left = left or vim.fn.input("DiffTool left path/ref: ")
  right = right or vim.fn.input("DiffTool right path/ref: ")

  local resolved_left = resolve_source(root, left)
  local resolved_right = resolve_source(root, right)
  if resolved_left and resolved_right then
    M.open(resolved_left, resolved_right)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("DiffToolLocal", M.local_changes, {
    desc = "Diff HEAD against current working tree",
  })

  vim.api.nvim_create_user_command("DiffToolUpstream", M.upstream_changes, {
    desc = "Diff upstream remote HEAD against current working tree",
  })

  vim.api.nvim_create_user_command("Diff", function(opts)
    if #opts.fargs == 2 then
      M.sources(opts.fargs[1], opts.fargs[2])
    else
      M.sources()
    end
  end, {
    nargs = "*",
    complete = "file",
    desc = "Diff two paths or git refs",
  })

  vim.keymap.set(
    "n",
    "<leader>dl",
    M.local_changes,
    { desc = "DiffTool local changes" }
  )
  vim.keymap.set(
    "n",
    "<leader>du",
    M.upstream_changes,
    { desc = "DiffTool upstream vs current" }
  )
  vim.keymap.set(
    "n",
    "<leader>dd",
    M.sources,
    { desc = "DiffTool two sources" }
  )

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      for _, path in ipairs(temp_paths) do
        vim.fn.delete(path, "rf")
      end
    end,
  })
end

return M
