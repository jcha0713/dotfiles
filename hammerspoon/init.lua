local inputEnglish = "com.apple.keylayout.ABC"

local function korToEng()
  local inputSource = hs.keycodes.currentSourceID()
  if not (inputSource == inputEnglish) then
    hs.keycodes.currentSourceID(inputEnglish)
  end
  hs.eventtap.keyStroke({}, "escape")
end

hs.hotkey.bind({ "control" }, 33, korToEng)
