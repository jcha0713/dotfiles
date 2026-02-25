-- luacheck: globals describe it assert
local Agents = require("99.extensions.agents")
local eq = assert.are.same

local function a(p)
  return vim.fs.joinpath(vim.uv.cwd(), p)
end

local custom_mds = {
  {
    name = "back-end",
    path = "scratch/custom_rules/back-end/SKILL.md",
    absolute_path = a("scratch/custom_rules/back-end/SKILL.md"),
  },
  {
    name = "foo",
    path = "scratch/custom_rules/foo/SKILL.md",
    absolute_path = a("scratch/custom_rules/foo/SKILL.md"),
  },
  {
    name = "front-end",
    path = "scratch/custom_rules/front-end/SKILL.md",
    absolute_path = a("scratch/custom_rules/front-end/SKILL.md"),
  },
  {
    name = "vim.lsp",
    path = "scratch/custom_rules/vim.lsp/SKILL.md",
    absolute_path = a("scratch/custom_rules/vim.lsp/SKILL.md"),
  },
  {
    name = "vim",
    path = "scratch/custom_rules/vim/SKILL.md",
    absolute_path = a("scratch/custom_rules/vim/SKILL.md"),
  },
  {
    name = "vim",
    path = "scratch/custom_rules_2/vim/SKILL.md",
    absolute_path = a("scratch/custom_rules_2/vim/SKILL.md"),
  },
  {
    name = "vim.treesitter",
    path = "scratch/custom_rules/vim.treesitter/SKILL.md",
    absolute_path = a("scratch/custom_rules/vim.treesitter/SKILL.md"),
  },
}

--- @param custom string | string[]
--- @return _99.State
local function r(custom)
  custom = type(custom) == "string" and { custom } or custom
  return {
    completion = {
      custom_rules = custom,
    },
  }
end

--- @param rules _99.Agents.Rules
--- @return string[]
local function get_names(rules)
  local names = {}
  local found = {}
  for _, rule in ipairs(rules.custom or {}) do
    if not found[rule.name] then
      found[rule.name] = true
      table.insert(names, rule.name)
    end
  end
  return names
end

--- @param rule_to_find _99.Agents.Rule
local function rule_exists(rule_to_find)
  for _, rule in ipairs(custom_mds) do
    if rule.name == rule_to_find.name and rule.path == rule_to_find.path then
      return
    end
  end
  assert(false, "could not find rule: " .. vim.inspect(rule_to_find))
end

describe("rules: <name>/SKILL.md", function()
  it("rules", function()
    local _99 = r({
      "scratch/custom_rules/",
      "scratch/custom_rules_2/",
    })
    local rules = Agents.rules(_99)
    local names = get_names(rules)
    eq(6, #names)
    for _, n in ipairs(names) do
      local rule_set = rules.by_name[n]
      eq("table", type(rule_set))
      eq(n == "vim" and 2 or 1, #rule_set)
      for _, rule in ipairs(rule_set) do
        rule_exists(rule)
      end
    end
  end)

  it("find rules", function()
    local _99 = r({
      "scratch/custom_rules/",
      "scratch/custom_rules_2/",
    })
    local rules = Agents.rules(_99)
    local prompt = "here is a test back-end #front-end and #vim.ls"
    local found = Agents.by_name(rules, prompt)

    eq({ "front-end" }, found.names)
    eq(rules.by_name["front-end"], found.rules)
  end)

  it("should validate that tokens exist by path and name", function()
    local _99 = r({
      "scratch/custom_rules/",
      "scratch/custom_rules_2/",
    })
    local rules = Agents.rules(_99)

    -- Test by path
    eq(true, Agents.is_rule(rules, "scratch/custom_rules/back-end/SKILL.md"))
    eq(true, Agents.is_rule(rules, "scratch/custom_rules/foo/SKILL.md"))
    eq(true, Agents.is_rule(rules, "scratch/custom_rules/front-end/SKILL.md"))
    eq(true, Agents.is_rule(rules, "scratch/custom_rules/vim.lsp/SKILL.md"))
    eq(true, Agents.is_rule(rules, "scratch/custom_rules/vim/SKILL.md"))
    eq(
      true,
      Agents.is_rule(rules, "scratch/custom_rules/vim.treesitter/SKILL.md")
    )

    -- Test by name
    eq(true, Agents.is_rule(rules, "back-end"))
    eq(true, Agents.is_rule(rules, "foo"))
    eq(true, Agents.is_rule(rules, "front-end"))
    eq(true, Agents.is_rule(rules, "vim"))

    -- Test invalid
    eq(false, Agents.is_rule(rules, "nonexistent"))
    eq(false, Agents.is_rule(rules, "invalid-token"))
    eq(false, Agents.is_rule(rules, ""))
  end)
end)
