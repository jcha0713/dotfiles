--# selene: allow(unused_variable)
---@diagnostic disable: unused-local

--- global variable containing loaded spoons
spoon = {}

-- Core Hammerspoon functionality
---@class hs
local M = {}
hs = M

-- Checks the Accessibility Permissions for Hammerspoon, and optionally allows you to prompt for permissions.
--
-- Parameters:
--  * shouldPrompt - an optional boolean value indicating if the dialog box asking if the System Preferences application should be opened should be presented when Accessibility is not currently enabled for Hammerspoon.  Defaults to false.
--
-- Returns:
--  * True or False indicating whether or not Accessibility is enabled for Hammerspoon.
--
-- Notes:
--  * Since this check is done automatically when Hammerspoon loads, it is probably of limited use except for skipping things that are known to fail when Accessibility is not enabled.  Evettaps which try to capture keyUp and keyDown events, for example, will fail until Accessibility is enabled and the Hammerspoon application is relaunched.
function M.accessibilityState(shouldPrompt, ...) end

-- An optional function that will be called when the Accessibility State is changed.
--
-- Notes:
--  * The function will not receive any arguments when called.  To check what the accessibility state has been changed to, you should call [hs.accessibilityState](#accessibilityState) from within your function.
M.accessibilityStateCallback = nil

-- Set or display whether or not external Hammerspoon AppleScript commands are allowed.
--
-- Parameters:
--  * state - an optional boolean which will set whether or not external Hammerspoon's AppleScript commands are allowed.
--
-- Returns:
--  * A boolean, `true` if Hammerspoon's AppleScript commands are (or has just been) allowed, otherwise `false`.
--
-- Notes:
--  * AppleScript access is disallowed by default.
--  * However due to the way AppleScript support works, Hammerspoon will always allow AppleScript commands that are part of the "Standard Suite", such as `name`, `quit`, `version`, etc. However, Hammerspoon will only allow commands from the "Hammerspoon Suite" if `hs.allowAppleScript()` is set to `true`.
--  * For a full list of AppleScript Commands:
--      - Open `/Applications/Utilities/Script Editor.app`
--      - Click `File > Open Dictionary...`
--      - Select Hammerspoon from the list of Applications
--      - This will now open a Dictionary containing all of the availible Hammerspoon AppleScript commands.
--  * Note that strings within the Lua code you pass from AppleScript can be delimited by `[[` and `]]` rather than normal quotes
--  * Example:
--    ```lua
--    tell application "Hammerspoon"
--      execute lua code "hs.alert([[Hello from AppleScript]])"
--    end tell```
---@return boolean
function M.allowAppleScript(state, ...) end

-- Set or display the "Launch on Login" status for Hammerspoon.
--
-- Parameters:
--  * state - an optional boolean which will set whether or not Hammerspoon should be launched automatically when you log into your computer.
--
-- Returns:
--  * True if Hammerspoon is currently (or has just been) set to launch on login or False if Hammerspoon is not.
---@return boolean
function M.autoLaunch(state, ...) end

-- Gets and optionally sets the Hammerspoon option to automatically check for updates.
--
-- Parameters:
--  * setting - an optional boolean variable indicating if Hammerspoon should (true) or should not (false) check for updates.
--
-- Returns:
--  * The current (or newly set) value indicating whether or not automatic update checks should occur for Hammerspoon.
--
-- Notes:
--  * If you are running a non-release or locally compiled version of Hammerspoon then the results of this function are unspecified.
---@return boolean
function M.automaticallyCheckForUpdates(setting, ...) end

-- Checks the Camera Permissions for Hammerspoon, and optionally allows you to prompt for permissions.
--
-- Parameters:
--  * shouldPrompt - an optional boolean value indicating if we should request camear access. Defaults to false.
--
-- Returns:
--  * `true` or `false` indicating whether or not Camera access is enabled for Hammerspoon.
--
-- Notes:
--  * Will always return `true` on macOS 10.13 or earlier.
---@return boolean
function M.cameraState(shouldPrompt, ...) end

-- Returns a boolean indicating whether or not the Sparkle framework is available to check for Hammerspoon updates.
--
-- Parameters:
--  * None
--
-- Returns:
--  * a boolean indicating whether or not the Sparkle framework is available to check for Hammerspoon updates
--
-- Notes:
--  * The Sparkle framework is included in all regular releases of Hammerspoon but not included if you are running a non-release or locally compiled version of Hammerspoon, so this function can be used as a simple test to determine whether or not you are running a formal release Hammerspoon or not.
---@return boolean
function M.canCheckForUpdates() end

-- Check for an update now, and if one is available, prompt the user to continue the update process.
--
-- Parameters:
--  * silent - An optional boolean. If true, no UI will be displayed if an update is available. Defaults to false.
--
-- Returns:
--  * None
--
-- Notes:
--  * If you are running a non-release or locally compiled version of Hammerspoon then the results of this function are unspecified.
function M.checkForUpdates(silent, ...) end

-- Returns a copy of the incoming string that can be displayed in the Hammerspoon console.  Invalid UTF8 sequences are converted to the Unicode Replacement Character and NULL (0x00) is converted to the Unicode Empty Set character.
--
-- Parameters:
--  * inString - the string to be cleaned up
--
-- Returns:
--  * outString - the cleaned up version of the input string.
--
-- Notes:
--  * This function is applied automatically to all output which appears in the Hammerspoon console, but not to the output provided by the `hs` command line tool.
--  * This function does not modify the original string - to actually replace it, assign the result of this function to the original string.
--  * This function is a more specifically targeted version of the `hs.utf8.fixUTF8(...)` function.
function M.cleanUTF8forConsole(inString, ...) end

-- Closes the Hammerspoon Console window
--
-- Parameters:
--  * None
--
-- Returns:
--  * None
function M.closeConsole() end

-- Closes the Hammerspoon Preferences window
--
-- Parameters:
--  * None
--
-- Returns:
--  * None
function M.closePreferences() end

-- Gathers tab completion options for the Console window
--
-- Parameters:
--  * completionWord - A string from the Console window's input field that completions are needed for
--
-- Returns:
--  * A table of strings, each of which will be shown as a possible completion option to the user
--
-- Notes:
--  * Hammerspoon provides a default implementation of this function, which can complete against the global Lua namespace, the 'hs' (i.e. extension) namespace, and object metatables. You can assign a new function to the variable to replace it with your own variant.
function M.completionsForInputString(completionWord, ...) end

-- A string containing Hammerspoon's configuration directory. Typically `~/.hammerspoon/`
M.configdir = nil

-- Set or display whether or not the Hammerspoon console is always on top when visible.
--
-- Parameters:
--  * state - an optional boolean which will set whether or not the Hammerspoon console is always on top when visible.
--
-- Returns:
--  * True if the console is currently set (or has just been) to be always on top when visible or False if it is not.
---@return boolean
function M.consoleOnTop(state, ...) end

-- Yield coroutine to allow the Hammerspoon application to process other scheduled events and schedule a resume in the event application queue.
--
-- Parameters:
--  * `delay` - an optional number, default `hs.math.minFloat`, specifying the number of seconds from when this function is executed that the `coroutine.resume` should be scheduled for.
--
-- Returns:
--  * None
--
-- Notes:
--  * this function will return an error if invoked outside of a coroutine.
--  * unlike `coroutine.yield`, this function does not allow the passing of (new) information to or from the coroutine while it is running; this function is to allow long running tasks to yield time to the Hammerspoon application so other timers and scheduled events can occur without requiring the programmer to add code for an explicit resume.
--
--  * this function is added to the lua `coroutine` library as `coroutine.applicationYield` as an alternative name.
function M.coroutineApplicationYield(delay, ...) end

-- Set or display whether or not the Hammerspoon dock icon is visible.
--
-- Parameters:
--  * state - an optional boolean which will set whether or not the Hammerspoon dock icon should be visible.
--
-- Returns:
--  * True if the icon is currently set (or has just been) to be visible or False if it is not.
--
-- Notes:
--  * This function is a wrapper to functions found in the `hs.dockicon` module, but is provided here to provide an interface consistent with other selectable preference items.
---@return boolean
function M.dockIcon(state, ...) end

-- An optional function that will be called when the Hammerspoon Dock Icon is clicked while the app is running
--
-- Notes:
--  * If set, this callback will be called regardless of whether or not Hammerspoon shows its console window in response to a click (which can be enabled/disabled via `hs.openConsoleOnDockClick()`
M.dockIconClickCallback = nil

-- A string containing the full path to the `docs.json` file inside Hammerspoon's app bundle. This contains the full Hammerspoon API documentation and can be accessed in the Console using `help("someAPI")`. It can also be loaded and processed by the `hs.doc` extension
M.docstrings_json_file = nil

-- Runs a shell command, optionally loading the users shell environment first, and returns stdout as a string, followed by the same result codes as `os.execute` would return.
--
-- Parameters:
--  * command - a string containing the shell command to execute
--  * with_user_env - optional boolean argument which if provided and is true, executes the command in the users login shell as an "interactive" login shell causing the user's local profile (or other login scripts) to be loaded first.
--
-- Returns:
--  * output -- the stdout of the command as a string.  May contain an extra terminating new-line (\n).
--  * status -- `true` if the command terminated successfully or nil otherwise.
--  * type   -- a string value of "exit" or "signal" indicating whether the command terminated of its own accord or if it was terminated by a signal (killed, segfault, etc.)
--  * rc     -- if the command exited of its own accord, then this number will represent the exit code (usually 0 for success, not 0 for an error, though this is very command specific, so check man pages when there is a question).  If the command was killed by a signal, then this number corresponds to the signal type that caused the command to terminate.
--
-- Notes:
--  * Setting `with_user_env` to true does incur noticeable overhead, so it should only be used if necessary (to set the path or other environment variables).
--  * Because this function returns the stdout as it's first return value, it is not quite a drop-in replacement for `os.execute`.  In most cases, it is probable that `stdout` will be the empty string when `status` is nil, but this is not guaranteed, so this trade off of shifting os.execute's results was deemed acceptable.
--  * This particular function is most useful when you're more interested in the command's output then a simple check for completion and result codes.  If you only require the result codes or verification of command completion, then `os.execute` will be slightly more efficient.
--  * If you need to execute commands that have spaces in their paths, use a form like: `hs.execute [["/Some/Path To/An/Executable" "--first-arg" "second-arg"]]`
function M.execute(command, with_user_env, ...) end

-- An optional function that will be called when a files are dragged to the Hammerspoon Dock Icon or sent via the Services menu
--
-- Notes:
--  * The function should accept a single parameter, which will be a string containing the full path to the file that was dragged to the dock icon
--  * If multiple files are sent, this callback will be called once for each file
--  * This callback will be triggered when ANY file type is dragged onto the Hammerspoon Dock Icon, however certain filetypes are also processed seperately by Hammerspoon. For example, `hs.urlevent` will be triggered when the following filetypes are dropped onto the Dock Icon: HTML Documents (.html, .htm, .shtml, .jhtml), Plain text documents (.txt, .text), Web site locations (.url), XHTML documents (.xhtml, .xht, .xhtm, .xht).
M.fileDroppedToDockIconCallback = nil

-- Makes Hammerspoon the foreground app.
--
-- Parameters:
--  * None
--
-- Returns:
--  * None
function M.focus() end

-- Fetches the Lua metatable for objects produced by an extension
--
-- Parameters:
--  * name - A string containing the name of a module to fetch object metadata for (e.g. `"hs.screen"`)
--
-- Returns:
--  * The extension's object metatable, or nil if an error occurred
function M.getObjectMetatable(name, ...) end

-- Prints the documentation for some part of Hammerspoon's API and Lua 5.3.  This function is actually sourced from hs.doc.help.
--
-- Parameters:
--  * identifier - A string containing the signature of some part of Hammerspoon's API (e.g. `"hs.reload"`)
--
-- Returns:
--  * None
--
-- Notes:
--  * This function is mainly for runtime API help while using Hammerspoon's Console
--  * You can also access the results of this function by the following methods from the console:
--    * help("identifier") -- quotes are required, e.g. `help("hs.reload")`
--    * help.identifier.path -- no quotes are required, e.g. `help.hs.reload`
--  * Lua information can be accessed by using the `lua` prefix, rather than `hs`.
--    * the identifier `lua._man` provides the table of contents for the Lua 5.3 manual.  You can pull up a specific section of the lua manual by including the chapter (and subsection) like this: `lua._man._3_4_8`.
--    * the identifier `lua._C` will provide information specifically about the Lua C API for use when developing modules which require external libraries.
function M.help(identifier, ...) end

-- Display's Hammerspoon API documentation in a webview browser.
--
-- Parameters:
--  * identifier - An optional string containing the signature of some part of Hammerspoon's API (e.g. `"hs.reload"`).  If no string is provided, then the table of contents for the Hammerspoon documentation is displayed.
--
-- Returns:
--  * None
--
-- Notes:
--  * You can also access the results of this function by the following methods from the console:
--    * hs.hsdocs.identifier.path -- no quotes are required, e.g. `hs.hsdocs.hs.reload`
--  * See `hs.doc.hsdocs` for more information about the available settings for the documentation browser.
--  * This function provides documentation for Hammerspoon modules, functions, and methods similar to the Hammerspoon Dash docset, but does not require any additional software.
--  * This currently only provides documentation for the built in Hammerspoon modules, functions, and methods.  The Lua documentation and third-party modules are not presently supported, but may be added in a future release.
function M.hsdocs(identifier, ...) end

-- Loads a Spoon
--
-- Parameters:
--  * name - The name of a Spoon (without the trailing `.spoon`)
--  * global - An optional boolean. If true, this function will insert the spoon into Lua's global namespace as `spoon.NAME`. Defaults to true.
--
-- Returns:
--  * The object provided by the Spoon (which can be ignored if you chose to make the Spoon global)
--
-- Notes:
--  * Spoons are a way of distributing self-contained units of Lua functionality, for Hammerspoon. For more information, see https://github.com/Hammerspoon/hammerspoon/blob/master/SPOON.md
--  * This function will load the Spoon and call its `:init()` method if it has one. If you do not wish this to happen, or wish to use a Spoon that somehow doesn't fit with the behaviours of this function, you can also simply `require('name')` to load the Spoon
--  * If the Spoon has a `:start()` method you are responsible for calling it before using the functionality of the Spoon.
--  * If the Spoon provides documentation, it will be loaded by made available in hs.docs
--  * To learn how to distribute your own code as a Spoon, see https://github.com/Hammerspoon/hammerspoon/blob/master/SPOON.md
function M.loadSpoon(name, global, ...) end

-- Set or display whether or not the Hammerspoon menu icon is visible.
--
-- Parameters:
--  * state - an optional boolean which will set whether or not the Hammerspoon menu icon should be visible.
--
-- Returns:
--  * True if the icon is currently set (or has just been) to be visible or False if it is not.
---@return boolean
function M.menuIcon(state, ...) end

-- Checks the Microphone Permissions for Hammerspoon, and optionally allows you to prompt for permissions.
--
-- Parameters:
--  * shouldPrompt - an optional boolean value indicating if we should request microphone access. Defaults to false.
--
-- Returns:
--  * `true` or `false` indicating whether or not Microphone access is enabled for Hammerspoon.
--
-- Notes:
--  * Will always return `true` on macOS 10.13 or earlier.
---@return boolean
function M.microphoneState(shouldPrompt, ...) end

-- Opens a file as if it were opened with /usr/bin/open
--
-- Parameters:
--  * filePath - A string containing the path to a file/bundle to open
--
-- Returns:
--  * A boolean, true if the file was opened successfully, otherwise false
function M.open(filePath, ...) end

-- Displays the OS X About panel for Hammerspoon; implicitly focuses Hammerspoon.
--
-- Parameters:
--  * None
--
-- Returns:
--  * None
function M.openAbout() end

-- Opens the Hammerspoon Console window and optionally focuses it.
--
-- Parameters:
--  * bringToFront - if true (default), the console will be focused as well as opened.
--
-- Returns:
--  * None
function M.openConsole(bringToFront, ...) end

-- Set or display whether or not the Console window will open when the Hammerspoon dock icon is clicked
--
-- Parameters:
--  * state - An optional boolean, true if the console window should open, false if not
--
-- Returns:
--  * A boolean, true if the console window will open when the dock icon
--
-- Notes:
--  * This only refers to dock icon clicks while Hammerspoon is already running. The console window is not opened by launching the app
---@return boolean
function M.openConsoleOnDockClick(state, ...) end

-- Displays the Hammerspoon Preferences panel; implicitly focuses Hammerspoon.
--
-- Parameters:
--  * None
--
-- Returns:
--  * None
function M.openPreferences() end

-- Set or display whether or not the Preferences panel should display in dark mode.
--
-- Parameters:
--  * state - an optional boolean which will set whether or not the Preferences panel should display in dark mode.
--
-- Returns:
--  * A boolean, true if dark mode is enabled otherwise false.
---@return boolean
function M.preferencesDarkMode(state, ...) end

-- Prints formatted strings to the Console
--
-- Parameters:
--  * format - A format string
--  * ... - Zero or more arguments to fill the placeholders in the format string
--
-- Returns:
--  * None
--
-- Notes:
--  * This is a simple wrapper around the Lua code `print(string.format(...))`.
function M.printf(format, ...) end

-- A table containing read-only information about the Hammerspoon application instance currently running.
M.processInfo = nil

-- The original Lua print() function
--
-- Parameters:
--  * aString - A string to be printed
--
-- Returns:
--  * None
--
-- Notes:
--  * Hammerspoon overrides Lua's print() function, but this is a reference we retain to is, should you need it for any reason
function M.rawprint(aString, ...) end

-- Quits and relaunches Hammerspoon.
--
-- Parameters:
--  * None
--
-- Returns:
--  * None
function M.relaunch() end

-- Reloads your init-file in a fresh Lua environment.
--
-- Parameters:
--  * None
--
-- Returns:
--  * None
function M.reload() end

-- Checks the Screen Recording Permissions for Hammerspoon, and optionally allows you to prompt for permissions.
--
-- Parameters:
--  * shouldPrompt - an optional boolean value indicating if the dialog box asking if the System Preferences application should be opened should be presented when Screen Recording is not currently enabled for Hammerspoon.  Defaults to false.
--
-- Returns:
--  * True or False indicating whether or not Screen Recording is enabled for Hammerspoon.
--
-- Notes:
--  * If you trigger the prompt and the user denies it, you cannot bring up the prompt again - the user must manually enable it in System Preferences.
function M.screenRecordingState(shouldPrompt, ...) end

-- Shows an error to the user, using Hammerspoon's Console
--
-- Parameters:
--  * err - A string containing an error message
--
-- Returns:
--  * None
--
-- Notes:
--  * This function is called whenever an (uncaught) error occurs or is thrown (via `error()`)
--  * The default implementation shows a notification, opens the Console, and prints the error message and stacktrace
--  * You can override this function if you wish to route errors differently (e.g. for remote systems)
function M.showError(err, ...) end

-- An optional function that will be called when the Lua environment is being destroyed (either because Hammerspoon is exiting or reloading its config)
--
-- Notes:
--  * This function should not perform any asynchronous tasks
--  * You do not need to fastidiously destroy objects you have created, this callback exists purely for utility reasons (e.g. serialising state, destroying system resources that will not be released by normal Lua garbage collection processes, etc)
M.shutdownCallback = nil

-- An optional function that will be called when text is dragged to the Hammerspoon Dock Icon or sent via the Services menu
--
-- Notes:
--  * The function should accept a single parameter, which will be a string containing the text that was dragged to the dock icon
M.textDroppedToDockIconCallback = nil

-- Toggles the visibility of the console
--
-- Parameters:
--  * None
--
-- Returns:
--  * None
--
-- Notes:
--  * If the console is not currently open, it will be opened. If it is open and not the focused window, it will be brought forward and focused.
--  * If the console is focused, it will be closed.
function M.toggleConsole() end

-- Gets the version & build number of an available update
--
-- Parameters:
--  * None
--
-- Returns:
--  * A string containing the display version of the latest release, or a boolean false if no update is available
--  * A string containing the build number of the latest release, or `nil` if no update is available
--
-- Notes:
--  * This is not a live check, it is a cached result of whatever the previous update check found. By default Hammerspoon checks for updates every few hours, but you can also add your own timer to check for updates more frequently with `hs.checkForUpdates()`
function M.updateAvailable() end

-- Get or set the "Upload Crash Data" preference for Hammerspoon
--
-- Parameters:
--  * state - An optional boolean, true to upload crash reports, false to not
--
-- Returns:
--  * True if Hammerspoon is currently (or has just been) set to upload crash data or False otherwise
--
-- Notes:
--  * If at all possible, please do allow Hammerspoon to upload crash reports to us, it helps a great deal in keeping Hammerspoon stable
--  * Our Privacy Policy can be found here: [https://www.hammerspoon.org/privacy.html](https://www.hammerspoon.org/privacy.html)
---@return boolean
function M.uploadCrashData(state, ...) end

--[[
-- CUSTOM EDITS FROM HERE
--]]

--, Simple on-screen alerts
---@type hs.alert
M.alert = nil

-- Easily find `hs.application` and `hs.window` objects
--
-- This module is *deprecated*; you can use `hs.window.find()`, `hs.window.get()`, `hs.application.find()`,
-- `hs.application.get()`, `hs.application:findWindow()` and `hs.application:getWindow()` instead.
---@type hs.appfinder
M.appfinder = nil

-- Execute AppleScript code
--
-- This module has been replaced by: [hs.osascript.applescript](./hs.osascript.html#applescript)
---@type hs.applescript
M.applescript = nil

-- Manipulate running applications
---@type hs.application
M.application = nil

-- Manipulate the system's audio devices
--
-- This module is based primarily on code from the previous incarnation of Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
---@type hs.audiodevice
M.audiodevice = nil

-- This module allows you to access the accessibility objects of running applications, their windows, menus, and other user interface elements that support the OS X accessibility API.
--
-- This module works through the use of axuielementObjects, which is the Hammerspoon representation for an accessibility object.  An accessibility object represents any object or component of an OS X application which can be manipulated through the OS X Accessibility API -- it can be an application, a window, a button, selected text, etc.  As such, it can only support those features and objects within an application that the application developers make available through the Accessibility API.
--
-- In addition to the formal methods described in this documentation, dynamic methods exist for accessing element attributes and actions. These will differ somewhat between objects as the specific attributes and actions will depend upon the accessibility object's role and purpose, but the following outlines the basics.
--
-- Getting and Setting Attribute values:
--  * `object.attribute` is a shortcut for `object:attributeValue(attribute)`
--  * `object.attribute = value` is a shortcut for `object:setAttributeValue(attribute, value)`
--    * If detecting accessiblity errors that may occur is necessary, you must use the formal methods [hs.axuielement:attributeValue](#attributeValue) and [hs.axuielement:setAttributeValue](#setAttributeValue)
--    * Note that setting an attribute value is not guaranteeed to work with either method:
--      * internal logic within the receiving application may decline to accept the newly assigned value
--      * an accessibility error may occur
--      * the element may not be settable (surprisingly this does not return an error, even when [hs.axuielement:isAttributeSettable](#isAttributeSettable) returns false for the attribute specified)
--    * If you require confirmation of the change, you will need to check the value of the attribute with one of the methods described above after setting it.
--
-- Iteration over Attributes:
--  * `for k,v in pairs(object) do ... end` is a shortcut for `for k,_ in ipairs(object:attributeNames()) do local v = object:attributeValue(k) ; ... end` or `for k,v in pairs(object:allAttributeValues()) do ... end` (though see note below)
--     * If detecting accessiblity errors that may occur is necessary, you must use one of the formal approaches [hs.axuielement:allAttributeValues](#allAttributeValues) or [hs.axuielement:attributeNames](#attributeNames) and [hs.axuielement:attributeValue](#attributeValue)
--    * By default, [hs.axuielement:allAttributeValues](#allAttributeValues) will not include key-value pairs for which the attribute (key) exists for the element but has no assigned value (nil) at the present time. This is because the value of `nil` prevents the key from being retained in the table returned. See [hs.axuielement:allAttributeValues](#allAttributeValues) for details and a workaround.
--
-- Iteration over Child Elements (AXChildren):
--  * `for i,v in ipairs(object) do ... end` is a shortcut for `for i,v in pairs(object:attributeValue("AXChildren") or {}) do ... end`
--    * Note that `object:attributeValue("AXChildren")` *may* return nil if the object does not have the `AXChildren` attribute; the shortcut does not have this limitation.
--  * `#object` is a shortcut for `#object:attributeValue("AXChildren")`
--  * `object[i]` is a shortcut for `object:attributeValue("AXChildren")[i]`
--    * If detecting accessiblity errors that may occur is necessary, you must use the formal method [hs.axuielement:attributeValue](#attributeValue) to get the "AXChildren" attribute.
--
-- Actions ([hs.axuielement:actionNames](#actionNames)):
--  * `object:do<action>()` is a shortcut for `object:performAction(action)`
--    * See [hs.axuielement:performAction](#performAction) for a description of the return values and [hs.axuielement:actionNames](#actionNames) to get a list of actions that the element supports.
--
-- ParameterizedAttributes:
--  * `object:<attribute>WithParameter(value)` is a shortcut for `object:parameterizedAttributeValue(attribute, value)
--    * See [hs.axuielement:parameterizedAttributeValue](#parameterizedAttributeValue) for a description of the return values and [hs.axuielement:parameterizedAttributeNames](#parameterizedAttributeNames) to get a list of parameterized values that the element supports
--
--    * The specific value required for a each parameterized attribute is different and is often application specific thus requiring some experimentation. Notes regarding identified parameter types and thoughts on some still being investigated will be provided in the Hammerspoon Wiki, hopefully shortly after this module becomes part of a Hammerspoon release.
---@type hs.axuielement
M.axuielement = nil

-- Base64 encoding and decoding
--
-- Portions sourced from (https://gist.github.com/shpakovski/1902994).
---@type hs.base64
M.base64 = nil

-- Battery/power information
-- All functions here may return nil, if the information requested is not available.
--
-- This module is based primarily on code from the previous incarnation of Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
---@type hs.battery
M.battery = nil

-- Find and publish network services advertised by multicast DNS (Bonjour) with Hammerspoon.
--
-- This module will allow you to discover services advertised on your network through multicast DNS and publish services offered by your computer.
---@type hs.bonjour
M.bonjour = nil

-- Inspect/manipulate display brightness
--
-- Home: https://github.com/asmagill/mjolnir_asm.sys
--
-- This module is based primarily on code from the previous incarnation of Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
---@type hs.brightness
M.brightness = nil

-- Control system power states (sleeping, preventing sleep, screen locking, etc)
--
-- **NOTE**: Any sleep preventions will be removed when hs.reload() is called. A future version of the module will save/restore state across reloads.
---@type hs.caffeinate
M.caffeinate = nil

-- Inspect the system's camera devices
---@type hs.camera
M.camera = nil

-- A different approach to drawing in Hammerspoon
--
-- `hs.drawing` approaches graphical images as independant primitives, each "shape" being a separate drawing object based on the core primitives: ellipse, rectangle, point, line, text, etc.  This model works well with graphical elements that are expected to be managed individually and don't have complex clipping interactions, but does not scale well when more complex combinations or groups of drawing elements need to be moved or manipulated as a group, and only allows for simple inclusionary clipping regions.
--
-- This module works by designating a canvas and then assigning a series of graphical primitives to the canvas.  Included in this assignment list are rules about how the individual elements interact with each other within the canvas (compositing and clipping rules), and direct modification of the canvas itself (move, resize, etc.) causes all of the assigned elements to be adjusted as a group.
--
-- The canvas elements are defined in an array, and each entry of the array is a table of key-value pairs describing the element at that position.  Elements are rendered in the order in which they are assigned to the array (i.e. element 1 is drawn before element 2, etc.).
--
-- Attributes for canvas elements are defined in [hs.canvas.attributes](#attributes). All canvas elements require the `type` field; all other attributes have default values.  Fields required to properly define the element (for example, `frame` for the `rectangle` element type) will be copied into the element definition with their default values if they are not specified at the time of creation. Optional attributes will only be assigned in the element definition if they are specified.  When the module requires the value for an element's attribute it first checks the element definition itself, then the defaults are looked for in the canvas defaults, and then finally in the module's built in defaults (specified in the descriptions below).
--
-- Some examples of how to use this module can be found at https://github.com/asmagill/hammerspoon/wiki/hs.canvas.examples
---@type hs.canvas
M.canvas = nil

-- Graphical, interactive tool for choosing/searching data
--
-- Notes:
--  * This module was influenced heavily by Choose, by Steven Degutis (https://github.com/sdegutis/choose)
---@type hs.chooser
M.chooser = nil

-- Some functions for manipulating the Hammerspoon console.
--
-- These functions allow altering the behavior and display of the Hammerspoon console.  They should be considered experimental, but have worked well for me.
---@type hs.console
M.console = nil

-- Various features/facilities for developers who are working on Hammerspoon itself, or writing extensions for it. It is extremely unlikely that you should need any part of this extension, in a normal user configuration.
---@type hs.crash
M.crash = nil

-- Controls for Deezer music player.
--
-- Heavily inspired by 'hs.spotify', credits to the original author.
---@type hs.deezer
M.deezer = nil

-- A collection of useful dialog boxes, alerts and panels for user interaction.
---@type hs.dialog
M.dialog = nil

-- Interact with NSDistributedNotificationCenter
-- There are many notifications posted by parts of OS X, and third party apps, which may be interesting to react to using this module.
--
-- You can discover the notifications that are being posted on your system with some code like this:
-- ```
-- foo = hs.distributednotifications.new(function(name, object, userInfo) print(string.format("name: %s\nobject: %s\nuserInfo: %s\n", name, object, hs.inspect(userInfo))) end)
-- foo:start()
-- ```
--
-- Note that distributed notifications are expensive - they involve lots of IPC. Also note that they are not guaranteed to be delivered, particularly if the system is very busy.
---@type hs.distributednotifications
M.distributednotifications = nil

-- Create documentation objects for interactive help within Hammerspoon
--
-- The documentation object created is a table with tostring metamethods allowing access to a specific functions documentation by appending the path to the method or function to the object created.
--
-- From the Hammerspoon console:
--
--       doc = require("hs.doc")
--       doc.hs.application
--
-- Results in:
--
--       Manipulate running applications
--
--       [submodules]
--       hs.application.watcher
--
--       [subitems]
--       hs.application:activate([allWindows]) -> bool
--       hs.application:allWindows() -> window[]
--           ...
--       hs.application:visibleWindows() -> win[]
--
-- By default, the internal core documentation and portions of the Lua 5.3 manual, located at http://www.lua.org/manual/5.3/manual.html, are already registered for inclusion within this documentation object, but you can register additional documentation from 3rd party modules with `hs.registerJSONFile(...)`.
---@type hs.doc
M.doc = nil

-- Control Hammerspoon's dock icon
--
-- This module is based primarily on code from the previous incarnation of Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
---@type hs.dockicon
M.dockicon = nil

-- DEPRECATED. Primitives for drawing on the screen in various ways.
--
-- hs.drawing is now deprecated and will be removed in a future release. Its functionality is now implemented by hs.canvas and you should migrate your code to using that directly. The API docs for hs.drawing remain here as a convenience.
---@type hs.drawing
M.drawing = nil

-- Tap into input events (mouse, keyboard, trackpad) for observation and possibly overriding them
-- It also provides convenience wrappers for sending mouse and keyboard events. If you need to construct finely controlled mouse/keyboard events, see hs.eventtap.event
--
-- This module is based primarily on code from the previous incarnation of Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
---@type hs.eventtap
M.eventtap = nil

-- Keyboard-driven expose replacement/enhancement
--
-- Warning: this module is still somewhat experimental.
-- Should you encounter any issues, please feel free to report them on https://github.com/Hammerspoon/hammerspoon/issues
-- or #hammerspoon on irc.libera.chat
--
-- With this module you can configure a hotkey to show thumbnails for open windows when invoked; each thumbnail will have
-- an associated keyboard "hint" (usually one or two characters) that you can type to quickly switch focus to that
-- window; in conjunction with keyboard modifiers, you can additionally minimize (`alt` by default) or close
-- (`shift` by default) any window without having to focus it first.
--
-- When used in combination with a windowfilter you can include or exclude specific apps, window titles, screens,
-- window roles, etc. Additionally, each expose instance can be customized to include or exclude minimized or hidden windows,
-- windows residing in other Mission Control Spaces, or only windows for the current application. You can further customize
-- hint length, colors, fonts and sizes, whether to show window thumbnails and/or titles, and more.
--
-- To improve responsiveness, this module will update its thumbnail layout in the background (so to speak), so that it
-- can show the expose without delay on invocation. Be aware that on particularly heavy Hammerspoon configurations
-- this could adversely affect overall performance; you can disable this behaviour with
-- `hs.expose.ui.fitWindowsInBackground=false`
--
-- Usage:
-- ```
-- -- set up your instance(s)
-- expose = hs.expose.new(nil,{showThumbnails=false}) -- default windowfilter, no thumbnails
-- expose_app = hs.expose.new(nil,{onlyActiveApplication=true}) -- show windows for the current application
-- expose_space = hs.expose.new(nil,{includeOtherSpaces=false}) -- only windows in the current Mission Control Space
-- expose_browsers = hs.expose.new{'Safari','Google Chrome'} -- specialized expose using a custom windowfilter
-- -- for your dozens of browser windows :)
--
-- -- then bind to a hotkey
-- hs.hotkey.bind('ctrl-cmd','e','Expose',function()expose:toggleShow()end)
-- hs.hotkey.bind('ctrl-cmd-shift','e','App Expose',function()expose_app:toggleShow()end)
-- ```
---@type hs.expose
M.expose = nil

-- Functional programming utility functions
---@type hs.fnutils
M.fnutils = nil

-- Access/inspect the filesystem
--
-- This module is partial superset of LuaFileSystem 1.8.0 (http://keplerproject.github.io/luafilesystem/). It has been modified to remove functions which do not apply to macOS filesystems and additional functions providing macOS specific filesystem information have been added.
---@type hs.fs
M.fs = nil

-- Utility object to represent points, sizes and rects in a bidimensional plane
--
-- An hs.geometry object can be:
--  * a *point*, or vector2, with `x` and `y` fields for its coordinates
--  * a *size* with `w` and `h` fields for width and height respectively
--  * a *rect*, which has both a point component for one of its corners, and a size component - so it has all 4 fields
--  * a *unit rect*, which is a rect with all fields between 0 and 1; it represents a "relative" rect within another (absolute) rect
--    (e.g. a unit rect `x=0,y=0 , w=0.5,h=0.5` is the quarter portion closest to the origin); please note that hs.geometry
--    makes no distinction internally between regular rects and unit rects; you can convert to and from as needed via the appropriate methods
--
-- You can create these objects in many different ways, via `my_obj=hs.geometry.new(...)` or simply `my_obj=hs.geometry(...)`
-- by passing any of the following:
--  * 4 parameters `X,Y,W,H` for the respective fields - W and H, or X and Y, can be `nil`:
--    * `hs.geometry(X,Y)` creates a point
--    * `hs.geometry(nil,nil,W,H)` creates a size
--    * `hs.geometry(X,Y,W,H)` creates a rect given its width and height from a corner
--  * a table `{X,Y}` creates a point
--  * a table `{X,Y,W,H}` creates a rect
--  * a table `{x=X,y=Y,w=W,h=H}` creates a rect, or if you omit X and Y, or W and H, creates a size or a point respectively
--  * a table `{x1=X1,y1=Y1,x2=X2,y2=Y2}` creates a rect, where X1,Y1 and X2,Y2 are the coordinates of opposite corners
--  * a string:
--    * `"X Y"` or `"X,Y"` creates a point
--    * `"WxH"` or `"W*H"` creates a size
--    * `"X Y/WxH"` or `"X,Y W*H"` (or variations thereof) creates a rect given its width and height from a corner
--    * `"X1,Y1>X2,Y2"` or `"X1 Y1 X2 Y2"` (or variations thereof) creates a rect given two opposite corners
--    * `"[X,Y WxH]"` or `"[X1,Y1 X2,Y2]"` or variations (note the square brackets) creates a unit rect where x=X/100, y=Y/100, w=W/100, h=H/100
--  * a point and a size `"X Y","WxH"` or `{x=X,y=Y},{w=W,h=H}` create a rect
--
-- You can use any of these anywhere an hs.geometry object is expected in Hammerspoon; the constructor will be called for you.
---@type hs.geometry
M.geometry = nil

-- Move/resize windows within a grid
--
-- The grid partitions your screens for the purposes of window management. The default layout of the grid is 3 columns by 3 rows.
-- You can specify different grid layouts for different screens and/or screen resolutions.
--
-- Windows that are aligned with the grid have their location and size described as a `cell`. Each cell is an `hs.geometry` rect with these fields:
--  * x - The column of the left edge of the window
--  * y - The row of the top edge of the window
--  * w - The number of columns the window occupies
--  * h - The number of rows the window occupies
--
-- For a grid of 3x3:
--  * a cell `'0,0 1x1'` will be in the upper-left corner
--  * a cell `'2,0 1x1'` will be in the upper-right corner
--  * and so on...
--
-- Additionally, a modal keyboard driven interface for interactive resizing is provided via `hs.grid.show()`;
-- The grid will be overlaid on the focused or frontmost window's screen with keyboard hints.
-- To resize/move the window, you can select the corner cells of the desired position.
-- For a move-only, you can select a cell and confirm with 'return'. The selected cell will become the new upper-left of the window.
-- You can also use the arrow keys to move the window onto adjacent screens, and the tab/shift-tab keys to cycle to the next/previous window.
-- Once you selected a cell, you can use the arrow keys to navigate through the grid. In this case, the grid will highlight the selected cells.
-- After highlighting enough cells, press enter to move/resize the window to the highlighted area.
---@type hs.grid
M.grid = nil

-- Various hashing algorithms
---@type hs.hash
M.hash = nil

-- HID interface for Hammerspoon, controls and queries caps lock state
--
-- Portions sourced from (https://discussions.apple.com/thread/7094207).
---@type hs.hid
M.hid = nil

-- Switch focus with a transient per-application keyboard shortcut
---@type hs.hints
M.hints = nil

-- Inspect information about the machine Hammerspoon is running on
--
-- Notes:
--  * The network/hostname calls can be slow, as network resolution calls can be called, which are synchronous and will block Hammerspoon until they complete.
---@type hs.host
M.host = nil

-- Create and manage global keyboard shortcuts
---@type hs.hotkey
M.hotkey = nil

-- Perform HTTP requests
---@type hs.http
M.http = nil

-- Simple HTTP server
--
-- Notes:
--  * Running an HTTP server is potentially dangerous, you should seriously consider the security implications of exposing your Hammerspoon instance to a network - especially to the Internet
--  * As a user of Hammerspoon, you are assumed to be highly capable, and aware of the security issues
---@type hs.httpserver
M.httpserver = nil

-- A module for capturing and manipulating image objects from other modules for use with hs.drawing.
--
---@type hs.image
M.image = nil

-- Produce human-readable representations of Lua variables (particularly tables)
--
-- This extension is based on inspect.lua by Enrique García Cota
-- https://github.com/kikito/inspect.lua
---@type hs.inspect
M.inspect = nil

-- Provides Hammerspoon with the ability to create both local and remote message ports for inter-process communication.
--
-- The most common use of this module is to provide support for the command line tool `hs` which can be added to your terminal shell environment with [hs.ipc.cliInstall](#cliInstall).  The command line tool will not work unless the `hs.ipc` module is loaded first, so it is recommended that you add `require("hs.ipc")` to your Hammerspoon `init.lua` file (usually located at ~/.hammerspoon/init.lua) so that it is always available when Hammerspoon is running.
--
-- This module is based heavily on code from Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
---@type hs.ipc
M.ipc = nil

-- Controls for iTunes music player
---@type hs.itunes
M.itunes = nil

-- Execute JavaScript code
--
-- This module has been replaced by: [hs.osascript.javascript](./hs.osascript.html#javascript)
---@type hs.javascript
M.javascript = nil

-- JSON encoding and decoding
--
-- This module is based partially on code from the previous incarnation of Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
--
---@type hs.json
M.json = nil

-- Convert between key-strings and key-codes. Also provides functionality for querying and changing keyboard layouts.
---@type hs.keycodes
M.keycodes = nil

-- Window layout manager
--
-- This extension allows you to trigger window placement/sizing to a number of windows at once
---@type hs.layout
M.layout = nil

-- Determine the machine's location and useful information about that location
--
-- This module provides functions for getting current location information and tracking location changes. It expands on the earlier version of the module by adding the ability to create independant locationObjects which can enable/disable location tracking independant of other uses of Location Services by Hammerspoon, adds region monitoring for exit and entry, and adds the retrieval of geocoding information through the `hs.location.geocoder` submodule.
--
-- This module is backwards compatible with its predecessor with the following changes:
--  * [hs.location.get](#get) - no longer requires that you invoke [hs.location.start](#start) before using this function. The information returned will be the last cached value, which is updated internally whenever additional WiFi networks are detected or lost (not necessarily joined). When update tracking is enabled with the [hs.location.start](#start) function, calculations based upon the RSSI of all currently seen networks are preformed more often to provide a more precise fix, but it's still based on the WiFi networks near you. In many cases, the value retrieved when the WiFi state is changed should be sufficiently accurate.
--  * [hs.location.servicesEnabled](#servicesEnabled) - replaces `hs.location.services_enabled`. While the earlier function is included for backwards compatibility, it will display a deprecation warning to the console the first time it is invoked and may go away completely in the future.
--
-- The following labels are used to describe tables which are used by functions and methods as parameters or return values in this module and in `hs.location.geocoder`. These tables are described as follows:
--
--  * `locationTable` - a table specifying location coordinates containing one or more of the following key-value pairs:
--    * `latitude`           - a number specifying the latitude in degrees. Positive values indicate latitudes north of the equator. Negative values indicate latitudes south of the equator. When not specified in a table being used as an argument, this defaults to 0.0.
--    * `longitude`          - a number specifying the longitude in degrees. Measurements are relative to the zero meridian, with positive values extending east of the meridian and negative values extending west of the meridian. When not specified in a table being used as an argument, this defaults to 0.0.
--    * `altitude`           - a number indicating altitude above (positive) or below (negative) sea-level. When not specified in a table being used as an argument, this defaults to 0.0.
--    * `horizontalAccuracy` - a number specifying the radius of uncertainty for the location, measured in meters. If negative, the `latitude` and `longitude` keys are invalid and should not be trusted. When not specified in a table being used as an argument, this defaults to 0.0.
--    * `verticalAccuracy`   - a number specifying the accuracy of the altitude value in meters. If negative, the `altitude` key is invalid and should not be trusted. When not specified in a table being used as an argument, this defaults to -1.0.
--    * `course`             - a number specifying the direction in which the device is traveling. If this value is negative, then the value is invalid and should not be trusted. On current Macintosh models, this will almost always be a negative number. When not specified in a table being used as an argument, this defaults to -1.0.
--    * `speed`              - a number specifying the instantaneous speed of the device in meters per second. If this value is negative, then the value is invalid and should not be trusted. On current Macintosh models, this will almost always be a negative number. When not specified in a table being used as an argument, this defaults to -1.0.
--    * `timestamp`          - a number specifying the time at which this location was determined. This number is the number of seconds since January 1, 1970 at midnight, GMT, and is a floating point number, so you should use `math.floor` on this number before using it as an argument to Lua's `os.date` function. When not specified in a table being used as an argument, this defaults to the current time.
--
--  * `regionTable` - a table specifying a circular region containing one or more of the following key-value pairs:
--    * `identifier`    - a string for use in identifying the region. When not specified in a table being used as an argument, a new value is generated with `hs.host.uuid`.
--    * `latitude`      - a number specifying the latitude in degrees. Positive values indicate latitudes north of the equator. Negative values indicate latitudes south of the equator. When not specified in a table being used as an argument, this defaults to 0.0.
--    * `longitude`     - a number specifying the latitude in degrees. Positive values indicate latitudes north of the equator. Negative values indicate latitudes south of the equator. When not specified in a table being used as an argument, this defaults to 0.0.
--    * `radius`        - a number specifying the radius (measured in meters) that defines the region’s outer boundary. When not specified in a table being used as an argument, this defaults to 0.0.
--    * `notifyOnEntry` - a boolean specifying whether or not a callback with the "didEnterRegion" message should be generated when the machine enters the region. When not specified in a table being used as an argument, this defaults to true.
--    * `notifyOnExit`  - a boolean specifying whether or not a callback with the "didExitRegion" message should be generated when the machine exits the region. When not specified in a table being used as an argument, this defaults to true.
---@type hs.location
M.location = nil

-- Simple logger for debugging purposes
--
-- Note: "methods" in this module are actually "static" functions - see `hs.logger.new()`
---@type hs.logger
M.logger = nil

-- Various helpful mathematical functions
--
-- This module includes, and is a superset of the built-in Lua `math` library so it is safe to do something like the following in your own code and still have access to both libraries:
--
--     local math = require("hs.math")
--     local n = math.sin(math.minFloat) -- works even though they're both from different libraries
--
-- The documentation for the math library can be found at http://www.lua.org/manual/5.3/ or from the Hammerspoon console via the help command: `help.lua.math`. This includes the following functions and variables:
--
--   * hs.math.abs        - help available via `help.lua.math.abs`
--   * hs.math.acos       - help available via `help.lua.math.acos`
--   * hs.math.asin       - help available via `help.lua.math.asin`
--   * hs.math.atan       - help available via `help.lua.math.atan`
--   * hs.math.ceil       - help available via `help.lua.math.ceil`
--   * hs.math.cos        - help available via `help.lua.math.cos`
--   * hs.math.deg        - help available via `help.lua.math.deg`
--   * hs.math.exp        - help available via `help.lua.math.exp`
--   * hs.math.floor      - help available via `help.lua.math.floor`
--   * hs.math.fmod       - help available via `help.lua.math.fmod`
--   * hs.math.huge       - help available via `help.lua.math.huge`
--   * hs.math.log        - help available via `help.lua.math.log`
--   * hs.math.max        - help available via `help.lua.math.max`
--   * hs.math.maxinteger - help available via `help.lua.math.maxinteger`
--   * hs.math.min        - help available via `help.lua.math.min`
--   * hs.math.mininteger - help available via `help.lua.math.mininteger`
--   * hs.math.modf       - help available via `help.lua.math.modf`
--   * hs.math.pi         - help available via `help.lua.math.pi`
--   * hs.math.rad        - help available via `help.lua.math.rad`
--   * hs.math.random     - help available via `help.lua.math.random`
--   * hs.math.randomseed - help available via `help.lua.math.randomseed`
--   * hs.math.sin        - help available via `help.lua.math.sin`
--   * hs.math.sqrt       - help available via `help.lua.math.sqrt`
--   * hs.math.tan        - help available via `help.lua.math.tan`
--   * hs.math.tointeger  - help available via `help.lua.math.tointeger`
--   * hs.math.type       - help available via `help.lua.math.type`
--   * hs.math.ult        - help available via `help.lua.math.ult`
--
-- Additional functions and values that are specific to Hammerspoon which provide expanded math support are documented here.
---@type hs.math
M.math = nil

-- Create and manage menubar icons
---@type hs.menubar
M.menubar = nil

-- Send messages via iMessage and SMS Relay (note, SMS Relay requires OS X 10.10 and an established SMS Relay pairing between your Mac and an iPhone running iOS8)
--
-- Note: This extension works by controlling the OS X "Messages" app via AppleScript, so you will need that app to be signed into an iMessage account
---@type hs.messages
M.messages = nil

-- MIDI Extension for Hammerspoon.
--
-- This extension supports listening, transmitting and synthesizing MIDI commands.
--
-- This extension was thrown together by [Chris Hocking](http://latenitefilms.com) for [CommandPost](http://commandpost.io).
--
-- This extension uses [MIKMIDI](https://github.com/mixedinkey-opensource/MIKMIDI), an easy-to-use Objective-C MIDI library created by Andrew Madsen and developed by him and Chris Flesner of [Mixed In Key](http://www.mixedinkey.com/).
--
-- MIKMIDI LICENSE:
-- Copyright (c) 2013 Mixed In Key, LLC.
-- Original author: [Andrew R. Madsen](https://github.com/armadsen) (andrew@mixedinkey.com)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
---@type hs.midi
M.midi = nil

-- Simple controls for the MiLight LED WiFi bridge (also known as LimitlessLED and EasyBulb)
---@type hs.milight
M.milight = nil

-- tmuxomatic-like window management
---@type hs.mjomatic
M.mjomatic = nil

-- Inspect/manipulate the position of the mouse pointer
--
-- This module is based primarily on code from the previous incarnation of Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
--
-- This module uses ManyMouse by Ryan C. Gordon.
--
-- MANYMOUSE LICENSE:
--
-- Copyright (c) 2005-2012 Ryan C. Gordon and others.
--
-- This software is provided 'as-is', without any express or implied warranty.
-- In no event will the authors be held liable for any damages arising from
-- the use of this software.
--
-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:
--
-- 1. The origin of this software must not be misrepresented; you must not
-- claim that you wrote the original software. If you use this software in a
-- product, an acknowledgment in the product documentation would be
-- appreciated but is not required.
--
-- 2. Altered source versions must be plainly marked as such, and must not be
-- misrepresented as being the original software.
--
-- 3. This notice may not be removed or altered from any source distribution.
--
--     Ryan C. Gordon <icculus@icculus.org>
---@type hs.mouse
M.mouse = nil

-- This module provides functions for inquiring about and monitoring changes to the network.
---@type hs.network
M.network = nil

-- Contains two low latency audio recognizers for different mouth noises, which can be used to trigger actions like scrolling or clicking.
-- The recognizers are also high accuracy and don't use much CPU time.
--
-- This module was written by [Tristan Hume](http://thume.ca/). If you have any issues with or questions about the recognition, email him.
-- All first person references in this module's documentation refer to him.
--
-- The detectors are tuned so that they work for most people and most microphones. For best results use a highly directional headset microphone so that it doesn't pick up other people and background
-- noises around you, and put the boom off to the side of your mouth so you aren't directly breathing on it.
--
-- The two mouth noises (and their corresponding event numbers) are:
--
-- ### "sssssssssss"
-- The "sssss" noise/syllable is easy to make and can be made continuously. The detector emits an event `1` when you start saying "sss" and a `2` after you stop.
-- It's good to hook up to variable-length actions like clicking/dragging and scrolling. It can detect very quiet noises so even just barely saying "ssss" under your
-- breath should trigger it without annoying anybody else around you too much. It works with most "sss" syllables but I find sharper is better, in crispness that is, loudness doesn't matter much.
-- It has a very low false negative rate, but often has false positives. It will obviously trigger in english speech since "s" is a common syllable, but with some microphones breathing in certain ways
-- will trigger it as well. Personally I use this to scroll down, it allows me to read long articles and books lying down with my laptop without awkward hand positioning to scroll with the trackpad.
--
-- ### Lip Popping
-- Popping your lips is harder to do reliably and can't be done for variable lengths of time. The detector calls your callback with the number `3` when it detects one.
-- This detector has an almost zero false positive rate in my experience and a very low false negative rate (when you manage to make the sound).
-- Personally I use this to scroll up by a large increment in case I scroll down too far with "sss", and when my RSS reader is focused it moves to the next article.
-- The only false positives I've ever had with this detector are various rare throat clearing noises that make a pop sound very much like a lip pop.
---@type hs.noises
M.noises = nil

-- This module allows you to create on screen notifications in the User Notification Center located at the right of the users screen.
--
-- Notifications can be sent immediately or scheduled for delivery at a later time, even if that scheduled time occurs when Hammerspoon is not currently running. Currently, if you take action on a notification while Hammerspoon is not running, the callback function is not honored for the first notification clicked upon -- This is expected to be fixed in a future release.
--
-- When setting up a callback function, you have the option of specifying it with the creation of the notification (hs.notify.new) or by pre-registering it with hs.notify.register and then referring it to by the tag name specified with hs.notify.register. If you use this registration method for defining your callback functions, and make sure to register all expected callback functions within your init.lua file or files it includes, then callback functions will remain available for existing notifications in the User Notification Center even if Hammerspoon's configuration is reloaded or if Hammerspoon is restarted. If the callback tag is not present when the user acts on the notification, the Hammerspoon console will be raised as a default action.
--
-- A shorthand, based upon the original inspiration for this module from Hydra and Mjolnir, hs.notify.show, is provided if you just require a quick and simple informative notification without the bells and whistles.
--
-- This module is based in part on code from the previous incarnation of Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
---@type hs.notify
M.notify = nil

-- Execute Open Scripting Architecture (OSA) code - AppleScript and JavaScript
--
---@type hs.osascript
M.osascript = nil

-- Inspect/manipulate pasteboards (more commonly called clipboards). Both the system default pasteboard and custom named pasteboards can be interacted with.
--
-- This module is based partially on code from the previous incarnation of Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
---@type hs.pasteboard
M.pasteboard = nil

-- Watch paths recursively for changes
--
-- This simple example watches your Hammerspoon directory for changes, and when it sees a change, reloads your configs:
--
--     local myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", hs.reload):start()
--
-- This module is based primarily on code from the previous incarnation of Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
---@type hs.pathwatcher
M.pathwatcher = nil

-- Read and write Property List files
---@type hs.plist
M.plist = nil

-- Razer device support.
--
-- This extension currently only supports the Razer Tartarus V2.
-- It allows you to trigger callbacks when you press buttons and use the
-- scroll wheel, as well as allowing you to change the LED backlights
-- on the buttons and scroll wheel, and control the three status lights.
--
-- By default, the Razer Tartarus V2 triggers regular keyboard commands
-- (i.e. pressing the "01" key will type "1"). However, you can use the
-- `:defaultKeyboardLayout(false)` method to prevent this. This works by
-- remapping the default shortcut keys to "dummy" keys, so that they
-- don't trigger regular keypresses in macOS.
--
-- Like the [`hs.streamdeck`](http://www.hammerspoon.org/docs/hs.streamdeck.html) extension, this extension has been
-- designed to be modular, so it's possible for others to develop support
-- for other Razer devices later down the line, if there's interest.
--
-- This extension was thrown together by [Chris Hocking](https://github.com/latenitefilms) for [CommandPost](https://commandpost.io).
--
-- This extension is based off the [`hs.streamdeck`](http://www.hammerspoon.org/docs/hs.streamdeck.html) extension by [Chris Jones](https://github.com/cmsj).
--
-- Special thanks to the authors of these awesome documents & resources:
--
--  - [Information on USB Packets](https://www.beyondlogic.org/usbnutshell/usb6.shtml)
--  - [AppleUSBDefinitions.h](https://lab.qaq.wiki/Lakr233/IOKit-deploy/-/blob/master/IOKit/usb/AppleUSBDefinitions.h)
--  - [hidutil key remapping generator for macOS](https://hidutil-generator.netlify.app)
--  - [macOS function key remapping with hidutil](https://www.nanoant.com/mac/macos-function-key-remapping-with-hidutil)
--  - [HID Device Property Keys](https://developer.apple.com/documentation/iokit/iohidkeys_h_user-space/hid_device_property_keys)
---@type hs.razer
M.razer = nil

-- Inverts and/or lowers the color temperature of the screen(s) on a schedule, for a more pleasant experience at night
--
-- Usage:
-- ```
-- -- make a windowfilterDisable for redshift: VLC, Photos and screensaver/login window will disable color adjustment and inversion
-- local wfRedshift=hs.window.filter.new({VLC={focused=true},Photos={focused=true},loginwindow={visible=true,allowRoles='*'}},'wf-redshift')
-- -- start redshift: 2800K + inverted from 21 to 7, very long transition duration (19->23 and 5->9)
-- hs.redshift.start(2800,'21:00','7:00','4h',true,wfRedshift)
-- -- allow manual control of inverted colors
-- hs.hotkey.bind(HYPER,'f1','Invert',hs.redshift.toggleInvert)
-- ```
--
-- Note:
--  * As of macOS 10.12.4, Apple provides "Night Shift", which implements a simple red-shift effect, as part of the OS. It seems unlikely that `hs.redshift` will see significant future development.
---@type hs.redshift
M.redshift = nil

-- Manipulate screens (i.e. monitors)
--
-- The macOS coordinate system used by Hammerspoon assumes a grid that spans all the screens (positioned as per
-- System Preferences->Displays->Arrangement). The origin `0,0` is at the top left corner of the *primary screen*.
-- (Screens to the left of the primary screen, or above it, and windows on these screens, will have negative coordinates)
---@type hs.screen
M.screen = nil

-- Communicate with external devices through a serial port (most commonly RS-232).
--
-- Powered by ORSSerialPort. Thrown together by @latenitefilms.
--
-- Copyright (c) 2011-2012 Andrew R. Madsen (andrew@openreelsoftware.com)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
---@type hs.serial
M.serial = nil

-- Serialize simple Lua variables across Hammerspoon launches
-- Settings must have a string key and must be made up of serializable Lua objects (string, number, boolean, nil, tables of such, etc.)
--
-- This module is based partially on code from the previous incarnation of Mjolnir by [Steven Degutis](https://github.com/sdegutis/).
--
---@type hs.settings
M.settings = nil

-- Share items with the macOS Sharing Services under the control of Hammerspoon.
--
-- This module will allow you to share Hammerspoon items with registered Sharing Services.  Some of the built-in sharing services include sharing through mail, Facebook, AirDrop, etc.  Other applications can add additional services as well.
--
-- For most sharing services (this has not been tested with all), the user will be prompted with the standard sharing dialog showing what is to be shared and offered a chance to submit or cancel.
--
-- This example prepares an email with a screenshot:
-- ~~~lua
-- mailer = hs.sharing.newShare("com.apple.share.Mail.compose")
-- mailer:subject("Screenshot generated at " .. os.date()):recipients({ "user@address.com" })
-- mailer:shareItems({ [[
--     Add any notes that you wish to add describing the screenshot here and click the Send icon when you are ready to send this
--
-- ]], hs.screen.mainScreen():snapshot() })
-- ~~~
--
-- Common item data types that can be shared with Sharing Services include (but are not necessarily limited to):
--  * basic data types like strings and numbers
--  * hs.image objects
--  * hs.styledtext objects
--  * web sites and other URLs through the use of the [hs.sharing.URL](#URL) function
--  * local files through the use of file URLs created with the [hs.sharing.fileURL](#fileURL) function
---@type hs.sharing
M.sharing = nil

-- List and run shortcuts from the Shortcuts app
--
-- Separate from this extension, Hammerspoon provides an action for use in the Shortcuts app.
-- The action is called "Execute Lua" and if it is passed a text block of valid Lua, it will execute that Lua within Hammerspoon.
-- You can use this action to call functions defined in your `init.lua` or to just execute chunks of Lua.
--
-- Your functions/chunks can return text, which will be returned by the action in Shortcuts.
---@type hs.shortcuts
M.shortcuts = nil

-- Talk to custom protocols using asynchronous TCP sockets
--
-- For UDP sockets see [`hs.socket.udp`](./hs.socket.udp.html)
--
-- `hs.socket` is implemented with [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket). CocoaAsyncSocket's [tagging features](https://github.com/robbiehanson/CocoaAsyncSocket/wiki/Intro_GCDAsyncSocket#reading--writing) provide a handy way to implement custom protocols.
--
-- For example, you can easily implement a basic HTTP client as follows (though using [`hs.http`](./hs.http.html) is recommended for the real world):
--
-- ```lua
-- local TAG_HTTP_HEADER, TAG_HTTP_CONTENT = 1, 2
-- local body = ""
-- local function httpCallback(data, tag)
--   if tag == TAG_HTTP_HEADER then
--     print(tag, "TAG_HTTP_HEADER"); print(data)
--     local contentLength = data:match("\r\nContent%-Length: (%d+)\r\n")
--     client:read(tonumber(contentLength), TAG_HTTP_CONTENT)
--   elseif tag == TAG_HTTP_CONTENT then
--     print(tag, "TAG_HTTP_CONTENT"); print(data)
--     body = data
--   end
-- end
--
-- client = hs.socket.new(httpCallback):connect("google.com", 80)
-- client:write("GET /index.html HTTP/1.0\r\nHost: google.com\r\n\r\n")
-- client:read("\r\n\r\n", TAG_HTTP_HEADER)
-- ```
--
-- Resulting in the following console output (adjust log verbosity with `hs.socket.setLogLevel()`) :
--
-- ```
--             LuaSkin: (secondary thread): TCP socket connected
--             LuaSkin: (secondary thread): Data written to TCP socket
--             LuaSkin: (secondary thread): Data read from TCP socket
-- 1 TAG_HTTP_HEADER
-- HTTP/1.0 301 Moved Permanently
-- Location: http://www.google.com/index.html
-- Content-Type: text/html; charset=UTF-8
-- Date: Thu, 03 Mar 2016 08:38:02 GMT
-- Expires: Sat, 02 Apr 2016 08:38:02 GMT
-- Cache-Control: public, max-age=2592000
-- Server: gws
-- Content-Length: 229
-- X-XSS-Protection: 1; mode=block
-- X-Frame-Options: SAMEORIGIN
--
--             LuaSkin: (secondary thread): Data read from TCP socket
-- 2 TAG_HTTP_CONTENT
-- &lt;HTML&gt;&lt;HEAD&gt;&lt;meta http-equiv=&quot;content-type&quot; content=&quot;text/html;charset=utf-8&quot;&gt;
-- &lt;TITLE&gt;301 Moved&lt;/TITLE&gt;&lt;/HEAD&gt;&lt;BODY&gt;
-- &lt;H1&gt;301 Moved&lt;/H1&gt;
-- The document has moved
-- &lt;A HREF=&quot;http://www.google.com/index.html&quot;&gt;here&lt;/A&gt;.
-- &lt;/BODY&gt;&lt;/HTML&gt;
--             LuaSkin: (secondary thread): TCP socket disconnected Socket closed by remote peer
-- ```
--
--
---@type hs.socket
M.socket = nil

-- Load/play/manipulate sound files
---@type hs.sound
M.sound = nil

-- This module provides some basic functions for controlling macOS Spaces.
--
-- The functionality provided by this module is considered experimental and subject to change. By using a combination of private APIs and Accessibility hacks (via hs.axuielement), some basic functions for controlling the use of Spaces is possible with Hammerspoon, but there are some limitations and caveats.
--
-- It should be noted that while the functions provided by this module have worked for some time in third party applications and in a previous experimental module that has received limited testing over the last few years, they do utilize some private APIs which means that Apple could change them at any time.
--
-- The functions which allow you to create new spaes, remove spaces, and jump to a specific space utilize `hs.axuielement` and perform accessibility actions through the Dock application to manipulate Mission Control. Because we are essentially directing the Dock to perform User Interactions, there is some visual feedback which we cannot entirely suppress. You can minimize, but not entirely remove, this by enabling "Reduce motion" in System Preferences -> Accessibility -> Display.
--
-- It is recommended that you also enable "Displays have separate Spaces" in System Preferences -> Mission Control.
--
-- This module is a distillation of my previous `hs._asm.undocumented.spaces` module, changes inspired by reviewing the `Yabai` source, and some experimentation with `hs.axuielement`. If you require more sophisticated control, I encourage you to check out https://github.com/koekeishiya/yabai -- it does require some additional setup (changes to SIP, possibly edits to `sudoers`, etc.) but may be worth the extra steps for some power users.
---@type hs.spaces
M.spaces = nil

-- This module provides access to the Speech Synthesizer component of OS X.
--
-- The speech synthesizer functions and methods provide access to OS X's Text-To-Speech capabilities and facilitates generating speech output both to the currently active audio device and to an AIFF file.
--
-- A discussion concerning the embedding of commands into the text to be spoken can be found at https://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/SpeechSynthesisProgrammingGuide/FineTuning/FineTuning.html#//apple_ref/doc/uid/TP40004365-CH5-SW6.  It is somewhat dated and specific to the older MacinTalk style voices, but still contains some information relevant to the more modern higer quality voices as well in its discussion about embedded commands.
---@type hs.speech
M.speech = nil

-- Utility and management functions for Spoons
-- Spoons are Lua plugins for Hammerspoon.
-- See https://www.hammerspoon.org/Spoons/ for more information
---@type hs.spoons
M.spoons = nil

-- Controls for Spotify music player
---@type hs.spotify
M.spotify = nil

-- This module allows Hammerspoon to preform Spotlight metadata queries.
--
-- This module will only be able to perform queries on volumes and folders which are not blocked by the Privacy settings in the System Preferences Spotlight panel.
--
-- A Spotlight query consists of two phases: an initial gathering phase where information currently in the Spotlight database is collected and returned, and a live-update phase which occurs after the gathering phase and consists of changes made to the Spotlight database, such as new entries being added, information in existing entries changing, or entities being removed.
--
-- The syntax for Spotlight Queries is beyond the scope of this module's documentation. It is a subset of the syntax supported by the Objective-C NSPredicate class.  Some references for this syntax can be found at:
--    * https://developer.apple.com/library/content/documentation/Carbon/Conceptual/SpotlightQuery/Concepts/QueryFormat.html
--    * https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html
--
-- Depending upon the callback messages enabled with the [hs.spotlight:callbackMessages](#callbackMessages) method, your callback assigned with the [hs.spotlight:setCallback](#setCallback) method, you can determine the query phase by noting which messages you have received.  During the initial gathering phase, the following callback messages may be observed: "didStart", "inProgress", and "didFinish".  Once the initial gathering phase has completed, you will only observe "didUpdate" messages until the query is stopped with the [hs.spotlight:stop](#stop) method.
--
-- You can also check to see if the initial gathering phase is in progress with the [hs.spotlight:isGathering](#isGathering) method.
--
-- You can access the individual results of the query with the [hs.spotlight:resultAtIndex](#resultAtIndex) method. For convenience, metamethods have been added to the spotlightObject which make accessing individual results easier:  an individual spotlightItemObject may be accessed from a spotlightObject by treating the spotlightObject like an array; e.g. `spotlightObject[n]` will access the n'th spotlightItemObject in the current results.
---@type hs.spotlight
M.spotlight = nil

-- Interact with SQLite databases
--
-- Notes:
--  * This module is LSQLite 0.9.5 as found at http://lua.sqlite.org/index.cgi/index
--  * It is unmodified apart from removing `db:load_extension()` as this feature is not available in Apple's libsqlite3.dylib
--  * For API documentation please see [http://lua.sqlite.org](http://lua.sqlite.org)
---@type hs.sqlite3
M.sqlite3 = nil

-- Configure/control an Elgato Stream Deck
--
-- Please note that in order for this module to work, the official Elgato Stream Deck app should not be running
--
-- This module would not have been possible without standing on the shoulders of others:
--  * https://github.com/OpenStreamDeck/StreamDeckSharp
--  * https://github.com/Lange/node-elgato-stream-deck
--  * Hopper
---@type hs.streamdeck
M.streamdeck = nil

-- This module adds support for controlling the style of the text in Hammerspoon.
--
-- More detailed documentation is being worked on and will be provided in the Hammerspoon Wiki at https://github.com/Hammerspoon/hammerspoon/wiki.  The documentation here is a condensed version provided for use within the Hammerspoon Dash docset and the inline help provided by the `help` console command within Hammerspoon.
--
-- The following list of attributes key-value pairs are recognized by this module and can be adjusted, set, or removed for objects by the various methods provided by this module.  The list of attributes is provided here for reference; anywhere in the documentation you see a reference to the `attributes key-value pairs`, refer back to here for specifics:
--
-- * `font`               - A table containing the font name and size, specified by the keys `name` and `size`.  Default is the System Font at 27 points for `hs.drawing` text objects; otherwise the default is Helvetica at 12 points.  You may also specify this as a string, which will be taken as the font named in the string at the default size, when setting this attribute.
-- * `color`              - A table indicating the color of the text as described in `hs.drawing.color`.  Default is white for hs.drawing text objects; otherwise the default is black.
-- * `backgroundColor`    - Default nil, no background color (transparent).
-- * `underlineColor`     - Default nil, same as `color`.
-- * `strikethroughColor` - Default nil, same as `color`.
-- * `strokeColor`        - Default nil, same as `color`.
-- * `strokeWidth`        - Default 0, no stroke; positive, stroke alone; negative, stroke and fill (a typical value for outlined text would be 3.0)
-- * `paragraphStyle`     - A table containing the paragraph style.  This table may contain any number of the following keys:
--     * `alignment`                     - A string indicating the texts alignment.  The string may contain a value of "left", "right", "center", "justified", or "natural". Default is "natural".
--     * `lineBreak`                     - A string indicating how text that doesn't fit into the drawingObjects rectangle should be handled.  The string may be one of "wordWrap", "charWrap", "clip", "truncateHead", "truncateTail", or "truncateMiddle".  Default is "wordWrap".
--     * `baseWritingDirection`          - A string indicating the base writing direction for the lines of text.  The string may be one of "natural", "leftToRight", or "rightToLeft".  Default is "natural".
--     * `tabStops`                      - An array of defined tab stops.  Default is an array of 12 left justified tab stops 28 points apart.  Each element of the array may contain the following keys:
--         * `location`                      - A floating point number indicating the number of points the tab stap is located from the line's starting margin (see baseWritingDirection).
--         * `tabStopType`                   - A string indicating the type of the tab stop: "left", "right", "center", or "decimal"
--     * `defaultTabInterval`            - A positive floating point number specifying the default tab stop distance in points after the last assigned stop in the tabStops field.
--     * `firstLineHeadIndent`           - A positive floating point number specifying the distance, in points, from the leading margin of a frame to the beginning of the paragraph's first line.  Default 0.0.
--     * `headIndent`                    - A positive floating point number specifying the distance, in points, from the leading margin of a text container to the beginning of lines other than the first.  Default 0.0.
--     * `tailIndent`                    - A floating point number specifying the distance, in points, from the margin of a frame to the end of lines. If positive, this value is the distance from the leading margin (for example, the left margin in left-to-right text). If 0 or negative, it's the distance from the trailing margin.  Default 0.0.
--     * `maximumLineHeight`             - A positive floating point number specifying the maximum height that any line in the frame will occupy, regardless of the font size. Glyphs exceeding this height will overlap neighboring lines. A maximum height of 0 implies no line height limit. Default 0.0.
--     * `minimumLineHeight`             - A positive floating point number specifying the minimum height that any line in the frame will occupy, regardless of the font size.  Default 0.0.
--     * `lineSpacing`                   - A positive floating point number specifying the space in points added between lines within the paragraph (commonly known as leading). Default 0.0.
--     * `paragraphSpacing`              - A positive floating point number specifying the space added at the end of the paragraph to separate it from the following paragraph.  Default 0.0.
--     * `paragraphSpacingBefore`        - A positive floating point number specifying the distance between the paragraph's top and the beginning of its text content.  Default 0.0.
--     * `lineHeightMultiple`            - A positive floating point number specifying the line height multiple. The natural line height of the receiver is multiplied by this factor (if not 0) before being constrained by minimum and maximum line height.  Default 0.0.
--     * `hyphenationFactor`             - The hyphenation factor, a value ranging from 0.0 to 1.0 that controls when hyphenation is attempted. By default, the value is 0.0, meaning hyphenation is off. A factor of 1.0 causes hyphenation to be attempted always.
--     * `tighteningFactorForTruncation` - A floating point number.  When the line break mode specifies truncation, the system attempts to tighten inter character spacing as an alternative to truncation, provided that the ratio of the text width to the line fragment width does not exceed 1.0 + the value of tighteningFactorForTruncation. Otherwise the text is truncated at a location determined by the line break mode. The default value is 0.05.
--     * `allowsTighteningForTruncation` - A boolean indicating whether the system may tighten inter-character spacing before truncating text. Only available in macOS 10.11 or newer. Default true.
--     * `headerLevel`                   - An integer number from 0 to 6 inclusive which specifies whether the paragraph is to be treated as a header, and at what level, for purposes of HTML generation.  Defaults to 0.
-- * `superscript`        - An integer indicating if the text is to be displayed as a superscript (positive) or a subscript (negative) or normal (0).
-- * `ligature`           - An integer. Default 1, standard ligatures; 0, no ligatures; 2, all ligatures.
-- * `strikethroughStyle` - An integer representing the strike-through line style.  See `hs.styledtext.lineStyles`, `hs.styledtext.linePatterns` and `hs.styledtext.lineAppliesTo`.
-- * `underlineStyle`     - An integer representing the underline style.  See `hs.styledtext.lineStyles`, `hs.styledtext.linePatterns` and `hs.styledtext.lineAppliesTo`.
-- * `baselineOffset`     - A floating point value, as points offset from baseline. Default 0.0.
-- * `kerning`            - A floating point value, as points by which to modify default kerning.  Default nil to use default kerning specified in font file; 0.0, kerning off; non-zero, points by which to modify default kerning.
-- * `obliqueness`        - A floating point value, as skew to be applied to glyphs.  Default 0.0, no skew.
-- * `expansion`          - A floating point value, as log of expansion factor to be applied to glyphs.  Default 0.0, no expansion.
-- * `shadow`             - Default nil, indicating no drop shadow.  A table describing the drop shadow effect for the text.  The table may contain any of the following keys:
--     * `offset`             - A table with `h` and `w` keys (a size structure) which specify horizontal and vertical offsets respectively for the shadow.  Positive values always extend down and to the right from the user's perspective.
--     * `blurRadius`         - A floating point value specifying the shadow's blur radius.  A value of 0 indicates no blur, while larger values produce correspondingly larger blurring. The default value is 0.
--     * `color`              - The default shadow color is black with an alpha of 1/3. If you set this property to nil, the shadow is not drawn.
--
-- To make the `hs.styledtext` objects easier to use, in addition to the module specific functions and methods defined, some of the Lua String library has been reproduced to perform similar functions on these objects.  See the help section for each method for more information on their use:
--
-- * `hs.styledtext:byte`
-- * `hs.styledtext:find`
-- * `hs.styledtext:gmatch`
-- * `hs.styledtext:len`
-- * `hs.styledtext:lower`
-- * `hs.styledtext:match`
-- * `hs.styledtext:rep`
-- * `hs.styledtext:sub`
-- * `hs.styledtext:upper`
--
-- In addition, the following metamethods have been included:
--
-- * concat:
--     * `string`..`object` yields the string values concatenated
--     * `object`..`string` yields a new `hs.styledtext` object with `string` appended
--     * two `hs.styledtext` objects yields a new `hs.styledtext` object containing the concatenation of the two objects
-- * len:     #object yields the length of the text contained in the object
-- * eq:      object ==/~= object yields a boolean indicating if the text of the two objects is equal or not.  Use `hs.styledtext:isIdentical` if you need to compare attributes as well.
-- * lt, le:  allows &lt;, &gt;, &lt;=, and &gt;= comparisons between objects and strings in which the text of an object is compared with the text of another or a Lua string.
--
-- Note that due to differences in the way Lua determines when to use metamethods for equality comparisons versus relative-position comparisons, ==/~= cannot compare an object to a Lua string (it will always return false because the types are different).  You must use object:getString() ==/~= `string`.  (see `hs.styledtext:getString`)
---@type hs.styledtext
M.styledtext = nil

-- Place the windows of an application into tabs drawn on its titlebar
---@type hs.tabs
M.tabs = nil

-- Tangent Control Surface Extension
--
-- **API Version:** TUBE Version 3.2 - TIPC Rev 4 (22nd February 2017)
--
-- This plugin allows Hammerspoon to communicate with Tangent's range of panels, such as their Element, Virtual Element Apps, Wave, Ripple and any future panels.
--
-- The Tangent Unified Bridge Engine (TUBE) is made up of two software elements, the Mapper and the Hub. The Hub communicates with your application via the
-- TUBE Inter Process Communications (TIPC). TIPC is a standardised protocol to allow any application that supports it to communicate with any current and
-- future panels produced by Tangent via the TUBE Hub.
--
-- You can download the Tangent Developer Support Pack & Tangent Hub Installer for Mac [here](http://www.tangentwave.co.uk/developer-support/).
--
-- This extension was thrown together by [Chris Hocking](https://github.com/latenitefilms), then dramatically improved by [David Peterson](https://github.com/randomeizer) for [CommandPost](http://commandpost.io).
---@type hs.tangent
M.tangent = nil

-- Execute processes in the background and capture their output
--
-- Notes:
--  * This is not intended to be used for processes which never exit. While it is possible to run such things with hs.task, it is not possible to read their output while they run and if they produce significant output, eventually the internal OS buffers will fill up and the task will be suspended.
--  * An hs.task object can only be used once
---@type hs.task
M.task = nil

-- Execute functions with various timing rules
--
-- **NOTE**: timers use NSTimer internally, which will be paused when computers sleep.
-- Especially, repeating timers won't be triggered at the specificed time when there are sleeps in between.
-- The workaround is to prevent system from sleeping, configured in Energy Saver in System Preferences.
---@type hs.timer
M.timer = nil

-- A generalized framework for working with OSX UI elements
---@type hs.uielement
M.uielement = nil

-- Allows Hammerspoon to respond to URLs
-- Hammerspoon is configured to react to URLs that start with `hammerspoon://` when they are opened by OS X.
-- This extension allows you to register callbacks for these URL events and their parameters, offering a flexible way to receive events from other applications.
--
-- You can also choose to make Hammerspoon the default for `http://` and `https://` URLs, which lets you route the URLs in your Lua code
--
-- Given a URL such as `hammerspoon://someEventToHandle?someParam=things&otherParam=stuff`, in the literal, RFC1808 sense of the URL, `someEventToHandle` is the hostname (or net_loc) of the URL, but given that these are not network resources, we consider `someEventToHandle` to be the name of the event. No path should be specified in the URL - it should consist purely of a hostname and, optionally, query parameters.
--
-- See also `hs.ipc` for a command line IPC mechanism that is likely more appropriate for shell scripts or command line use. Unlike `hs.ipc`, `hs.urlevent` is not able to return any data to its caller.
--
-- NOTE: If Hammerspoon is not running when a `hammerspoon://` URL is opened, Hammerspoon will be launched, but it will not react to the URL event. Nor will it react to any events until this extension is loaded and event callbacks have been bound.
-- NOTE: Any event which is received, for which no callback has been bound, will be logged to the Hammerspoon Console
-- NOTE: When you trigger a URL from another application, it is usually best to have the URL open in the background, if that option is available. Otherwise, OS X will activate Hammerspoon (i.e. give it focus), which makes URL events difficult to use for things like window management.
---@type hs.urlevent
M.urlevent = nil

-- Inspect USB devices
---@type hs.usb
M.usb = nil

-- Functions providing basic support for UTF-8 encodings
--
-- Prior to upgrading Hammerspoon's Lua interpreter to 5.3, UTF8 support was provided by including the then beta version of Lua 5.3's utf8 library as a Hammerspoon module.  This is no longer necessary, but to maintain compatibility, the Lua utf8 library can still be accessed through `hs.utf8`.  The documentation for the utf8 library can be found at http://www.lua.org/manual/5.3/ or from the Hammerspoon console via the help command: `help.lua.utf8`. This affects the following functions and variables:
--
--   * hs.utf8.char          - help available via `help.lua.utf8.char`
--   * hs.utf8.charPattern   - help available via `help.lua.utf8.charpattern`
--   * hs.utf8.codepoint     - help available via `help.lua.utf8.codepoint`
--   * hs.utf8.codes         - help available via `help.lua.utf8.codes`
--   * hs.utf8.len           - help available via `help.lua.utf8.len`
--   * hs.utf8.offset        - help available via `help.lua.utf8.offset`
--
-- Additional functions that are specific to Hammerspoon which provide expanded support for UTF8 are documented here.
--
---@type hs.utf8
M.utf8 = nil

-- Controls for VOX music player
---@type hs.vox
M.vox = nil

-- A minimalistic Key-Value-Observer framework for Lua.
--
-- This module allows you to generate a table with a defined label or path that can be used to share data with other modules or code.  Other modules can register as watchers to a specific key-value pair within the watchable object table and will be automatically notified when the key-value pair changes.
--
-- The goal is to provide a mechanism for sharing state information between separate and (mostly) unrelated code easily and in an independent fashion.
---@type hs.watchable
M.watchable = nil

-- Simple websocket client.
---@type hs.websocket
M.websocket = nil

-- Display web content in a window from Hammerspoon
--
-- This module uses Apple's WebKit WKWebView class to provide web content display with JavaScript injection support.  The objective is to provide a functional interface to the WKWebView and WKUserContentController classes.
--
-- This module is not intended to replace a full web browser and does have some limitations to keep in mind:
--   * Self-signed SSL certificates are not accepted unless they have first been approved and included in the users Keychain by another method, for example, opening the page first in Safari.
--   * The context-menu (right clicking or ctrl-clicking in the webview) provides some menu items which are currently unsupported -- a known example of this is any "Download..." menu item in the context menu for links and images.
--   * It is uncertain at present exactly how or where cookies and cached page data is stored or how it can be invalidated.
--     * This can be mitigated to an extent for web requests by using `hs.webview:reload(true)` and by crafting the url for `hs.webview:url({...})` as a table -- see the appropriate help entries for more information.
--
-- Any suggestions or updates to the code to address any of these or other limitations as they may become apparent are welcome at the Hammerspoon github site: https://www.github.com/Hammerspoon/hammerspoon
--
---@type hs.webview
M.webview = nil

-- Inspect WiFi networks
---@type hs.wifi
M.wifi = nil

-- Inspect/manipulate windows
--
-- Notes:
--  * See `hs.screen` and `hs.geometry` for more information on how Hammerspoon uses window/screen frames and coordinates
---@type hs.window
M.window = nil
