local M = {}

---@class sasu.FeederOptions
---@field enabled? boolean
---@field command? string
---@field throttle_ms? number
---@field include_timestamp? boolean
---@field notify_on_error? boolean

---@class sasu.FeederState
---@field opts sasu.FeederOptions
---@field group integer|nil
---@field last_sent_by_file table<string, number>
---@field dropped integer

---@type sasu.FeederOptions
local defaults = {
  enabled = true,
  command = '/sasu-memory-ingest-nvim-save',
  throttle_ms = 500,
  include_timestamp = true,
  notify_on_error = false,
}

---@type sasu.FeederState
local state = {
  opts = vim.deepcopy(defaults),
  group = nil,
  last_sent_by_file = {},
  dropped = 0,
}

---@return number
local function now_ms()
  if vim.uv and type(vim.uv.now) == 'function' then
    return vim.uv.now()
  end
  if vim.loop and type(vim.loop.now) == 'function' then
    return math.floor(vim.loop.now())
  end
  return math.floor(os.clock() * 1000)
end

---@return string
local function iso_now_utc()
  return os.date('!%Y-%m-%dT%H:%M:%S.000Z')
end

---@param abs string
---@return string
local function normalize_path(abs)
  local normalized = vim.fs and vim.fs.normalize and vim.fs.normalize(abs) or abs
  return normalized:gsub('\\', '/')
end

---@param file string|nil
---@return string|nil
local function resolve_absolute_file(file)
  if type(file) ~= 'string' or file == '' then
    return nil
  end

  local absolute = vim.fn.fnamemodify(file, ':p')
  if type(absolute) ~= 'string' or absolute == '' then
    return nil
  end

  return normalize_path(absolute)
end

---@param bufnr integer
---@return boolean
local function should_skip_buffer(bufnr)
  if bufnr <= 0 or not vim.api.nvim_buf_is_valid(bufnr) then
    return true
  end
  local bo = vim.bo[bufnr]
  if bo.buftype ~= '' then
    return true
  end
  if bo.modifiable == false then
    return true
  end
  return false
end

---@param abs_file string
---@return boolean
local function should_throttle(abs_file)
  local window = tonumber(state.opts.throttle_ms) or 0
  if window <= 0 then
    return false
  end

  local now = now_ms()
  local last = state.last_sent_by_file[abs_file]
  if not last then
    return false
  end

  return (now - last) < window
end

---@param abs_file string
local function mark_sent(abs_file)
  state.last_sent_by_file[abs_file] = now_ms()
end

---@return table|nil terminal_module
---@return table|nil terminal
---@return string|nil error
local function current_pi_terminal()
  local ok, terminal_module = pcall(require, 'pi-nvim.cli.terminal')
  if not ok then
    return nil, nil, 'pi-nvim is not available'
  end

  if type(terminal_module.get_current) ~= 'function' or type(terminal_module.send) ~= 'function' then
    return nil, nil, 'pi-nvim terminal API unavailable'
  end

  local terminal = terminal_module.get_current()
  if not terminal then
    return nil, nil, 'Pi terminal is not open'
  end

  if type(terminal_module.is_open) == 'function' and not terminal_module.is_open(terminal) then
    return nil, nil, 'Pi terminal is not visible'
  end

  if not terminal.job or terminal.job <= 0 then
    return nil, nil, 'Pi terminal job is not running'
  end

  return terminal_module, terminal, nil
end

---@param abs_file string
---@return boolean
---@return string|nil
local function emit_save(abs_file)
  local terminal_module, terminal, err = current_pi_terminal()
  if not terminal_module or not terminal then
    return false, err
  end

  local payload = {
    file = abs_file,
  }

  if state.opts.include_timestamp then
    payload.ts = iso_now_utc()
  end

  local encoded = vim.json.encode(payload)
  local command = string.format('%s %s\n', state.opts.command, encoded)
  terminal_module.send(terminal, command)
  return true, nil
end

---@param err string
local function maybe_notify_error(err)
  if not state.opts.notify_on_error then
    return
  end
  vim.notify('[sasu-feeder] ' .. err, vim.log.levels.WARN)
end

---@param name string
---@param fn function
---@param opts table
local function create_or_replace_user_command(name, fn, opts)
  pcall(vim.api.nvim_del_user_command, name)
  vim.api.nvim_create_user_command(name, fn, opts)
end

---@param args table
local function on_buf_write(args)
  if not state.opts.enabled then
    return
  end

  local bufnr = args.buf or 0
  if should_skip_buffer(bufnr) then
    return
  end

  local abs_file = resolve_absolute_file(args.file)
  if not abs_file then
    return
  end

  if should_throttle(abs_file) then
    return
  end

  local ok, err = emit_save(abs_file)
  if ok then
    mark_sent(abs_file)
    return
  end

  if err then
    state.dropped = state.dropped + 1
    maybe_notify_error(err)
  end
end

function M.enable()
  state.opts.enabled = true
end

function M.disable()
  state.opts.enabled = false
end

---@return table
function M.status()
  local _, terminal, err = current_pi_terminal()
  return {
    enabled = state.opts.enabled,
    command = state.opts.command,
    throttle_ms = state.opts.throttle_ms,
    include_timestamp = state.opts.include_timestamp,
    terminal_ready = terminal ~= nil,
    terminal_error = terminal and nil or err,
    dropped = state.dropped,
  }
end

function M.emit_current()
  local bufnr = vim.api.nvim_get_current_buf()
  if should_skip_buffer(bufnr) then
    vim.notify('[sasu-feeder] Current buffer is not a writable file buffer', vim.log.levels.WARN)
    return
  end

  local abs = resolve_absolute_file(vim.api.nvim_buf_get_name(bufnr))
  if not abs then
    vim.notify('[sasu-feeder] Current buffer has no file path', vim.log.levels.WARN)
    return
  end

  local ok, err = emit_save(abs)
  if not ok then
    vim.notify('[sasu-feeder] Failed to emit save signal: ' .. tostring(err), vim.log.levels.WARN)
    return
  end

  mark_sent(abs)
  vim.notify('[sasu-feeder] Emitted save signal for ' .. abs, vim.log.levels.INFO)
end

---@param opts? sasu.FeederOptions
function M.setup(opts)
  state.opts = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {})

  local group = vim.api.nvim_create_augroup('sasu_nvim_feeder', { clear = true })
  state.group = group

  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    callback = on_buf_write,
    desc = 'Emit SASU memory save signal to Pi terminal',
  })

  create_or_replace_user_command('SasuFeederStatus', function()
    vim.notify(vim.inspect(M.status()), vim.log.levels.INFO)
  end, { desc = 'Show SASU Neovim feeder status' })

  create_or_replace_user_command('SasuFeederEnable', function()
    M.enable()
    vim.notify('[sasu-feeder] enabled', vim.log.levels.INFO)
  end, { desc = 'Enable SASU Neovim feeder' })

  create_or_replace_user_command('SasuFeederDisable', function()
    M.disable()
    vim.notify('[sasu-feeder] disabled', vim.log.levels.INFO)
  end, { desc = 'Disable SASU Neovim feeder' })

  create_or_replace_user_command('SasuFeederEmitCurrent', function()
    M.emit_current()
  end, { desc = 'Emit SASU save signal for current file' })
end

return M
