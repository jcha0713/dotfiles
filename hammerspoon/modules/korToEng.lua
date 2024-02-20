local M = {}
local utils = require("utils")
local inputUSEnglish = "com.apple.keylayout.US"

local changeSource = function()
  local inputSource = hs.keycodes.currentSourceID()
  if not (inputSource == inputUSEnglish) then
    hs.keycodes.currentSourceID(inputUSEnglish)
  end
  hs.eventtap.keyStroke({}, "escape")
end

function M.init()
  utils.bind({ "control" }, 33, changeSource)
end

return M
