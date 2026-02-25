--- @class _99.ops.Opts
--- @field additional_prompt? string
--- @field additional_rules? _99.Agents.Rule[]

--- @class _99.ops.SearchOpts : _99.ops.Opts
--- @field open_on_results? boolean
--- @field open_to_qfix? boolean

return {
  search = require("99.ops.search"),
  implement_fn = require("99.ops.implement-fn"),
  over_range = require("99.ops.over-range"),
}
