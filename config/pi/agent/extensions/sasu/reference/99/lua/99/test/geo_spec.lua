-- luacheck: globals describe it assert before_each after_each
local geo = require("99.geo")
local Point = geo.Point
local Range = geo.Range
local test_utils = require("99.test.test_utils")
local eq = assert.are.same

describe("Range", function()
  local buffer

  before_each(function()
    buffer = test_utils.create_file({
      "function foo()",
      "  local x = 1",
      "  return x",
      "end",
      "",
      "function bar()",
      "  return 42",
      "end",
    }, "lua", 1, 0)
  end)

  after_each(function()
    test_utils.clean_files()
  end)

  it("replace text", function()
    local start_point = Point:from_1_based(2, 3)
    local end_point = Point:from_1_based(3, 11)
    local range = Range:new(buffer, start_point, end_point)
    local original_text = range:to_text()
    eq("local x = 1\n  return x", original_text)

    local replace_text = { "local y = 2" }
    range:replace_text(replace_text)
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
    eq({
      "function foo()",
      "  local y = 2",
      "end",
      "",
      "function bar()",
      "  return 42",
      "end",
    }, lines)
  end)

  it("replace text single line into multi-line", function()
    local start_point = Point:from_1_based(2, 3)
    local end_point = Point:from_1_based(3, 11)
    local range = Range:new(buffer, start_point, end_point)
    local original_text = range:to_text()
    eq("local x = 1\n  return x", original_text)

    local replace_text = {
      "local y = 2",
      "  local z = 3",
    }
    range:replace_text(replace_text)
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
    eq({
      "function foo()",
      "  local y = 2",
      "  local z = 3",
      "end",
      "",
      "function bar()",
      "  return 42",
      "end",
    }, lines)
  end)

  it(
    "should be able to visual line select an empty line and return out an empty line of text",
    function()
      vim.api.nvim_win_set_cursor(0, { 5, 0 })
      vim.api.nvim_feedkeys("V", "x", false)

      test_utils.next_frame()
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
        "x",
        false
      )

      local range = Range.from_visual_selection()
      local text = range:to_text()
      eq("", text)
    end
  )

  it("should create range from simple visual line selection", function()
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
    vim.api.nvim_feedkeys("V", "x", false)

    test_utils.next_frame()
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
      "x",
      false
    )

    local range = Range.from_visual_selection()
    local text = range:to_text()
    eq("  local x = 1", text)
  end)

  it(
    "should handle from_visual_selection when visual marks point past buffer end",
    function()
      local small_buffer = test_utils.create_file({
        "line one",
        "line two",
      }, "lua", 1, 0)

      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      vim.fn.setpos("'<", { small_buffer, 1, 1, 0 })
      vim.fn.setpos("'>", { small_buffer, 100, 1, 0 })
      local range = Range.from_visual_selection()

      eq(
        Range:new(
          small_buffer,
          Point:from_1_based(1, 1),
          Point:from_1_based(2, 9) --- we capture the full line "line two\n"
        ),
        range
      )
    end
  )

  it(
    "should handle from_visual_selection when buffer has been modified",
    function()
      -- Create buffer with some content
      local mod_buffer = test_utils.create_file({
        "function test()",
        "  return 1",
        "  return 2",
        "  return 3",
        "end",
      }, "lua", 1, 0)

      -- Make a visual selection on lines 2-4
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      vim.api.nvim_feedkeys("V2j", "x", false)
      test_utils.next_frame()
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
        "x",
        false
      )

      -- Now delete lines from the buffer, making the visual marks stale
      vim.api.nvim_buf_set_lines(mod_buffer, 0, -1, false, { "only one line" })

      -- The visual marks still point to old positions that no longer exist
      -- This should not crash
      local ok, err = pcall(Range.from_visual_selection)
      assert.is_true(ok, "from_visual_selection crashed: " .. tostring(err))
    end
  )

  it("should handle from_visual_selection on empty buffer", function()
    -- Create an empty buffer
    local empty_buffer = test_utils.create_file({}, "lua", 1, 0)

    -- Set visual marks that would be invalid for empty buffer
    vim.fn.setpos("'<", { empty_buffer, 1, 1, 0 })
    vim.fn.setpos("'>", { empty_buffer, 1, 1, 0 })

    -- This should not crash
    local ok, err = pcall(Range.from_visual_selection)
    assert.is_true(
      ok,
      "from_visual_selection crashed on empty buffer: " .. tostring(err)
    )
  end)
end)
