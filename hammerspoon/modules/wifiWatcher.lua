local M = {}

local homeSSID = hs.settings.get("secret").ssid
local lastSSID = hs.wifi.currentNetwork()

local function changeNetwork()
  local newSSID = hs.wifi.currentNetwork()

  if newSSID ~= nil then
    if homeSSID ~= newSSID and lastSSID == homeSSID then
      hs.alert("you're not home")
      if newSSID == "eduroam" or newSSID == "University of Washington" then
        local address = hs.settings.get("secret").contacts.mj.address
        hs.messages.iMessage(
          address,
          hs.settings.get("secret").contacts.mj.message.uw
        )
        hs.notify.new({
          title = "wifiWatcher",
          informativeText = "iMessage was sent to " .. address,
        }):send()
      end

      hs.audiodevice.defaultOutputDevice():setVolume(0)
      hs.notify.new({
        title = "wifiWatcher",
        informativeText = "Connected to "
          .. newSSID
          .. ". The volume is set to 0.",
      }):send()
    elseif newSSID == homeSSID and lastSSID ~= homeSSID then
      hs.alert("home")
      local address = hs.settings.get("secret").contacts.mj.address
      hs.messages.iMessage(
        address,
        hs.settings.get("secret").contacts.mj.message.home
      )
      hs.notify.new({
        title = "wifiWatcher",
        informativeText = "iMessage was sent to " .. address,
      }):send()
      hs.audiodevice.defaultOutputDevice():setVolume(50)
      hs.notify.new({
        title = "wifiWatcher",
        informativeText = "Connected to "
          .. newSSID
          .. ". The volume is set to 50.",
      }):send()
    end

    lastSSID = newSSID
  end
end

function M.init()
  local wifiWatcher = hs.wifi.watcher.new(changeNetwork)
  print("initializing the wifiWatcher module ... ")
  wifiWatcher:start()
end

return M
