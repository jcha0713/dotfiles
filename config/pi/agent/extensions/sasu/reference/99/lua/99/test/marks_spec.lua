-- luacheck: globals describe it assert before_each after_each
local Mark = require("99.ops.marks")
local geo = require("99.geo")
local Point = geo.Point
local Range = geo.Range
local test_utils = require("99.test.test_utils")
local eq = assert.are.same

describe("Mark", function()
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

  it("should get mark point from visual selection", function()
    local _, buf = test_utils.fif_setup({
      "local test_1 = 0",
      "local test_2 = 0",
      "local test_3 = 0",
      "local test_4 = 0",
      "local test_5 = 0",
      "local test_6 = 0",
    }, 2, 0, "lua")

    vim.api.nvim_feedkeys("V", "x", false)

    test_utils.next_frame()
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
      "x",
      false
    )

    local range = Range.from_visual_selection()
    local mark = Mark.mark_point(buf, range.end_)
    eq(Point.from_mark(mark), Point:from_1_based(2, 17))
  end)

  it("should create a mark at a specific point", function()
    local point = Point:from_1_based(2, 3)
    local mark = Mark.mark_point(buffer, point)
    local mark_point = Point.from_mark(mark)

    eq(point, mark_point)

    mark:delete()
  end)

  it("marks range", function()
    local start_point = Point:from_1_based(2, 3)
    local end_point = Point:from_1_based(3, 10)
    local range = Range:new(buffer, start_point, end_point)
    local mark_start, mark_end = Mark.mark_range(range)
    local actual_start = Point.from_mark(mark_start)
    local actual_end = Point.from_mark(mark_end)

    eq(start_point, actual_start)
    eq(end_point, actual_end)

    mark_start:delete()
    mark_end:delete()
  end)

  it("should handle single-line ranges", function()
    local start_point = Point:from_1_based(2, 3)
    local end_point = Point:from_1_based(2, 10)
    local range = Range:new(buffer, start_point, end_point)
    local mark_start, mark_end = Mark.mark_range(range)
    local actual_start = Point.from_mark(mark_start)
    local actual_end = Point.from_mark(mark_end)

    eq(start_point, actual_start)
    eq(end_point, actual_end)

    mark_start:delete()
    mark_end:delete()
  end)

  it("should create mark one line above the range start", function()
    local above_point = Point:from_1_based(2, 14)
    local start_point = Point:from_1_based(3, 5)
    local end_point = Point:from_1_based(4, 3)
    local range = Range:new(buffer, start_point, end_point)
    local mark = Mark.mark_above_range(range)
    local mark_point = Point.from_mark(mark)

    eq(above_point, mark_point)

    mark:delete()
  end)

  it("should create mark at beginning when range starts at line 1", function()
    local start_point = Point:from_1_based(1, 5)
    local end_point = Point:from_1_based(2, 3)
    local range = Range:new(buffer, start_point, end_point)
    local mark = Mark.mark_above_range(range)
    local mark_point = Point.from_mark(mark)

    local beginning_point = Point:from_1_based(1, 1)
    eq(beginning_point, mark_point)
    mark:delete()
  end)

  it("should create mark at the end of the range", function()
    local start_point = Point:from_1_based(2, 3)
    local end_point = Point:from_1_based(3, 8)
    local range = Range:new(buffer, start_point, end_point)
    local mark = Mark.mark_end_of_range(buffer, range)
    local mark_point = Point.from_mark(mark)
    local expected_end_point = end_point:add(Point:from_1_based(0, 1))

    eq(expected_end_point, mark_point)

    mark:delete()
  end)

  it("should create mark above a function", function()
    local func_start = Point:from_1_based(6, 1)
    local func_end = Point:from_1_based(8, 4)
    local func_range = Range:new(buffer, func_start, func_end)
    local mock_func = {
      function_range = func_range,
    }

    local mark = Mark.mark_above_func(buffer, mock_func)
    local mark_point = Point.from_mark(mark)
    local expected_mark_point = func_start:sub(Point:from_1_based(1, 0))

    eq(expected_mark_point, mark_point)
    mark:delete()
  end)

  it(
    "should handle mark_above_func when function starts at first line (row 1)",
    function()
      local func_start = Point:from_1_based(1, 1)
      local func_end = Point:from_1_based(4, 4)
      local func_range = Range:new(buffer, func_start, func_end)
      local mock_func = {
        function_range = func_range,
      }

      local mark = Mark.mark_above_func(buffer, mock_func)
      local mark_point = Point.from_mark(mark)
      eq(1, mark_point.row)
      mark:delete()
    end
  )

  it("should create mark at function body start", function()
    local func_start = Point:from_1_based(6, 1)
    local func_end = Point:from_1_based(8, 4)
    local func_range = Range:new(buffer, func_start, func_end)
    local mock_func = {
      function_range = func_range,
    }
    local mark = Mark.mark_func_body(buffer, mock_func)
    local mark_point = Point.from_mark(mark)

    eq(func_start, mark_point)

    mark:delete()
  end)

  it("should delete the extmark", function()
    local point = Point:from_1_based(2, 3)
    local mark = Mark.mark_point(buffer, point)
    local mark_pos = Point.from_mark(mark)
    eq(point, mark_pos)
    mark:delete()

    local deleted_pos =
      vim.api.nvim_buf_get_extmark_by_id(mark.buffer, mark.nsid, mark.id, {})
    eq(0, #deleted_pos)
  end)
end)
