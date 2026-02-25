---@param context _99.RequestContext
---@param name string
---@param clean_up_fn fun(): nil
---@return fun(): nil
return function(context, name, clean_up_fn)
  local called = false
  local request_id = -1
  local function clean_up()
    if called then
      return
    end

    called = true
    clean_up_fn()
    context._99:remove_active_request(request_id)
  end
  request_id = context._99:add_active_request(clean_up, context.xid, name)

  return clean_up
end
