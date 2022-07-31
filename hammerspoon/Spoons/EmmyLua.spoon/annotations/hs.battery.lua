--# selene: allow(unused_variable)
---@diagnostic disable: unused-local

-- Battery/power information
-- All functions here may return nil, if the information requested is not available.
--
-- This module is based primarily on code from the previous incarnation of Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
---@class hs.battery
local M = {}
hs.battery = M

-- Returns the amount of current flowing through the battery, in mAh
--
-- Parameters:
--  * None
--
-- Returns:
--  * A number containing the amount of current flowing through the battery. The value may be:
--   * Less than zero if the battery is being discharged (i.e. the computer is running on battery power)
--   * Zero if the battery is being neither charged nor discharged
--   * Greater than zero if the battery is being charged
---@return number
function M.amperage() end

-- Returns the current capacity of the battery in mAh
--
-- Parameters:
--  * None
--
-- Returns:
--  * A number containing the current capacity of the battery in mAh
--
-- Notes:
--  * This is the measure of how charged the battery is, vs the value of `hs.battery.maxCapacity()`
---@return number
function M.capacity() end

-- Returns the number of discharge cycles of the battery
--
-- Parameters:
--  * None
--
-- Returns:
--  * The number of cycles
--
-- Notes:
--  * One cycle is a full discharge of the battery, followed by a full charge. This may also be an aggregate of many smaller discharge-then-charge cycles (e.g. 10 iterations of discharging the battery from 100% to 90% and then charging back to 100% each time, is considered to be one cycle)
---@return number
function M.cycles() end

-- Returns the design capacity of the battery in mAh.
--
-- Parameters:
--  * None
--
-- Returns:
--  * A number containing the rated maximum capacity of the battery
---@return number
function M.designCapacity() end

-- Get all available battery information
--
-- Parameters:
--  * None
--
-- Returns:
--  * A table containing all the information provided by the separate functions in hs.battery
--
-- Notes:
--  * If you require multiple pieces of information about a battery, this function may be more efficient than calling several other functions separately
function M.getAll() end

-- Returns the health status of the battery.
--
-- Parameters:
--  * None
--
-- Returns:
--  * A string containing one of {Good, Fair, Poor}, as determined by the Apple Smart Battery controller
---@return string
function M.health() end

-- Returns the health condition status of the battery.
--
-- Parameters:
--  * None
--
-- Returns:
--  * Nil if there are no health conditions to report, or a string containing either:
--   * "Check Battery"
--   * "Permanent Battery Failure"
function M.healthCondition() end

-- Returns the charged state of the battery
--
-- Parameters:
--  * None
--
-- Returns:
--  * True if the battery is charged, false if not
---@return boolean
function M.isCharged() end

-- Returns the charging state of the battery
--
-- Parameters:
--  * None
--
-- Returns:
--  * True if the battery is being charged, false if not
---@return boolean
function M.isCharging() end

-- Returns true if battery is finishing its charge
--
-- Parameters:
--  * None
--
-- Returns:
--  * True if the battery is in its final charging state (i.e. trickle charging), false if not, or "n/a" if the battery is not charging at all
function M.isFinishingCharge() end

-- Returns the maximum capacity of the battery in mAh
--
-- Parameters:
--  * None
--
-- Returns:
--  * A number containing the observed maximum capacity of the battery in mAh
--
-- Notes:
--  * This may exceed the value of `hs.battery.designCapacity()` due to small variations in the production chemistry vs the design
---@return number
function M.maxCapacity() end

-- Returns the name of the battery
--
-- Parameters:
--  * None
--
-- Returns:
--  * A string containing the name of the battery
---@return string
function M.name() end

-- Returns information about non-PSU batteries (e.g. bluetooth accessories)
--
-- Parameters:
--  * None
--
-- Returns:
--  * A table containing information about other batteries known to the system, or an empty table if no devices were found
function M.otherBatteryInfo() end

-- Returns the current percentage of battery charge
--
-- Parameters:
--  * None
--
-- Returns:
--  * A number containing the percentage of battery charge
---@return number
function M.percentage() end

-- Returns current source of power
--
-- Parameters:
--  * None
--
-- Returns:
--  * A string containing one of {AC Power, Battery Power, Off Line}.
---@return string
function M.powerSource() end

-- Returns information about Bluetooth devices using Apple Private APIs
--
-- Parameters:
--  * None
--
-- Returns:
--  * A table containing information about devices using private Apple APIs.
--
-- Notes:
--  * This function uses private Apple APIs - that means it can break without notice on any macOS version update. Please report breakage to us!
--  * This function will return information for all connected Bluetooth devices, but much of it will be meaningless for most devices
--  * The table contains the following keys:
--    * vendorID - Numerical identifier for the vendor of the device (Apple's ID is 76)
--    * productID - Numerical identifier for the device
--    * address - The bluetooth address of the device
--    * isApple - A string containing "YES" or "NO", depending on whether or not this is an Apple/Beats product, or a third party product
--    * name - A human readable string containing the name of the device
--    * batteryPercentSingle - For some devices this will contain the percentage of the battery (e.g. Beats headphones)
--    * batteryPercentCombined - We do not currently understand what this field represents, please report if you find a non-zero value here
--    * batteryPercentCase - Battery percentage of AirPods cases (note that this will often read 0 - the AirPod case sleeps aggressively)
--    * batteryPercentLeft - Battery percentage of the left AirPod if it is out of the case
--    * batteryPercentRight - Battery percentage of the right AirPod if it is out of the case
--    * buttonMode - We do not currently understand what this field represents, please report if you find a value other than 1
--    * micMode - For AirPods this corresponds to the microphone option in the device's Bluetooth options
--    * leftDoubleTap - For AirPods this corresponds to the left double tap action in the device's Bluetooth options
--    * rightDoubleTap - For AirPods this corresponds to the right double tap action in the device's Bluetooth options
--    * primaryBud - For AirPods this is either "left" or "right" depending on which bud is currently considered the primary device
--    * primaryInEar - For AirPods this is "YES" or "NO" depending on whether or not the primary bud is currently in an ear
--    * secondaryInEar - For AirPods this is "YES" or "NO" depending on whether or not the secondary bud is currently in an ear
--    * isInEarDetectionSupported - Whether or not this device can detect when it is currently in an ear
--    * isEnhancedDoubleTapSupported - Whether or not this device supports double tapping
--    * isANCSupported - We believe this likely indicates whether or not this device supports Active Noise Cancelling (e.g. Beats Solo)
--  * Please report any crashes from this function - it's likely that there are Bluetooth devices we haven't tested which may return weird data
--  * Many/Most/All non-Apple party products will likely return zeros for all of the battery related fields here, as will Apple HID devices. It seems that these private APIs mostly exist to support Apple/Beats headphones.
function M.privateBluetoothBatteryInfo() end

-- Returns the serial number of the attached power supply, if present
--
-- Parameters:
--  * None
--
-- Returns:
--  * An integer containing the power supply's serial number, or 0 if no serial can be found
---@return number
function M.psuSerial() end

-- Returns the serial string of the attached power supply, if present
--
-- Parameters:
--  * None
--
-- Returns:
--  * A string containing the power supply's serial, or an empty string if no serial can be found
---@return string
function M.psuSerialString() end

-- Returns the battery life remaining, in minutes
--
-- Parameters:
--  * None
--
-- Returns:
--  * A number containing the minutes of battery life remaining. The value may be:
--   * Greater than zero to indicate the number of minutes remaining
--   * -1 if the remaining battery life is still being calculated
--   * -2 if there is unlimited time remaining (i.e. the system is on AC power)
---@return number
function M.timeRemaining() end

-- Returns the time remaining for the battery to be fully charged, in minutes
--
-- Parameters:
--  * None
--
-- Returns:
--  * A number containing the time (in minutes) remaining for the battery to be fully charged, or -1 if the remaining time is still being calculated
---@return number
function M.timeToFullCharge() end

-- Returns the current voltage of the battery in mV
--
-- Parameters:
--  * None
--
-- Returns:
--  * A number containing the current voltage of the battery
---@return number
function M.voltage() end

-- Returns the power entering or leaving the battery, in W
--
-- Parameters:
--  * None
--
-- Returns:
--  * A number containing the rate of energy conversion in the battery. The value may be:
--   * Less than zero if the battery is being discharged (i.e. the computer is running on battery power)
--   * Zero if the battery is being neither charged nor discharged
--   * Greater than zero if the battery is being charged
---@return number
function M.watts() end

-- Watch for battery/power state changes
--
-- This module is based primarily on code from the previous incarnation of Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
---@type hs.battery.watcher
M.watcher = nil
