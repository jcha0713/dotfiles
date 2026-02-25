---- PURELY AI GENERATED FILE -----
---- This could be crap test, i did about ~15 second code review,
----  looks mostly correct, a little weird, but close enough ----
local Throbber = require("99.ops.throbber")
local eq = assert.are.same

describe("Throbber", function()
  it(
    "cycles through throb, cooldown, and restart phases, then stops",
    function()
      local test_icons = { "a", "b", "c", "d", "e" }
      local original_icons = Throbber._icons
      Throbber._icons = { test_icons }

      -- Define timings for predictable testing
      local timings = {
        throb_time = 600,
        cooldown_time = 200,
      }

      local received = {}
      local states = {}
      --- @type _99.Throbber
      local throbber
      throbber = Throbber.new(function(icon)
        table.insert(received, icon)
        table.insert(states, throbber.state)
      end, timings)
      throbber.throb_fn = function(percent)
        local index = math.floor(percent * #test_icons) + 1
        return test_icons[math.min(index, #test_icons)]
      end

      -- Start throbbing
      throbber:start()
      vim.wait(timings.throb_time * 0.7)

      -- Verify we cycled through multiple icons (throb phase)
      local seen_icons = {}
      for _, icon in ipairs(received) do
        seen_icons[icon] = true
      end
      assert.is_true(
        seen_icons["a"] and seen_icons["b"] and seen_icons["c"],
        "Expected to cycle through multiple icons during throb phase"
      )

      -- Wait for cooldown (should stay on first icon)
      local icon_count_before_cooldown = #received
      vim.wait(timings.cooldown_time + timings.throb_time * 0.3)

      -- Verify cooldown: stays on last icon
      local cooldown_icons = {}
      for i = icon_count_before_cooldown + 1, #received do
        table.insert(cooldown_icons, received[i])
      end
      for _, icon in ipairs(cooldown_icons) do
        eq("e", icon, "Expected cooldown to stay on last icon")
      end

      -- Wait for second throb cycle to start
      vim.wait(timings.throb_time * 0.5)

      -- Verify we transitioned back to throbbing state
      local seen_throbbing = false
      local seen_cooldown = false
      local seen_second_throb = false
      for _, state in ipairs(states) do
        if state == "throbbing" then
          if not seen_throbbing then
            seen_throbbing = true
          elseif seen_cooldown then
            seen_second_throb = true
          end
        elseif state == "cooldown" then
          seen_cooldown = true
        end
      end
      assert.is_true(seen_throbbing, "Expected to see throbbing state")
      assert.is_true(seen_cooldown, "Expected to see cooldown state")
      assert.is_true(
        seen_second_throb,
        "Expected to see second throbbing cycle"
      )

      -- Stop the throbber
      throbber:stop()
      local count_after_stop = #received

      -- Verify no more updates after stop
      vim.wait(300)
      eq(count_after_stop, #received, "Expected no more updates after stop")

      Throbber._icons = original_icons
    end
  )
end)
