local M = {}
local utils = require("utils")
local inputEnglish = "com.apple.keylayout.ABC"

local changeSource = function()
  local inputSource = hs.keycodes.currentSourceID()
  if not (inputSource == inputEnglish) then
    hs.keycodes.currentSourceID(inputEnglish)
  end
  hs.eventtap.keyStroke({}, "escape")
end

function M.init()
  utils.bind({ "control" }, 33, changeSource)
end

return M
