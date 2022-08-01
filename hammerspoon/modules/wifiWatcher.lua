local M = {}

local homeSSID = hs.settings.get("secret").ssid
local lastSSID = hs.wifi.currentNetwork()

local function changeNetwork()
  local newSSID = hs.wifi.currentNetwork()

  if homeSSID ~= newSSID and lastSSID == homeSSID then
    hs.audiodevice.defaultOutputDevice():setVolume(0)
    hs.alert("Connected to" .. newSSID .. ". The volume is set to 0.")
  elseif newSSID == homeSSID and lastSSID ~= homeSSID then
    hs.audiodevice.defaultOutputDevice():setVolume(50)
    hs.alert("Connected to" .. newSSID .. ". The volume is set to 50.")
  end

  lastSSID = newSSID
end

function M:init()
  local wifiWatcher = hs.wifi.watcher.new(changeNetwork)
  wifiWatcher:start()
end

return M
