--# selene: allow(unused_variable)
---@diagnostic disable: unused-local

-- A generalized framework for working with OSX UI elements
---@class hs.uielement
local M = {}
hs.uielement = M

-- Gets the currently focused UI element
--
-- Parameters:
--  * None
--
-- Returns:
--  * An `hs.uielement` object or nil if no object could be found
function M.focusedElement() end

-- Returns whether the UI element represents an application.
--
-- Parameters:
--  * None
--
-- Returns:
--  * A boolean, true if the UI element is an application
---@return boolean
function M:isApplication() end

-- Returns whether the UI element represents a window.
--
-- Parameters:
--  * None
--
-- Returns:
--  * A boolean, true if the UI element is a window, otherwise false
---@return boolean
function M:isWindow() end

-- Creates a new watcher
--
-- Parameters:
--  * A function to be called when a watched event occurs.  The function will be passed the following arguments:
--    * element: The element the event occurred on. Note this is not always the element being watched.
--    * event: The name of the event that occurred.
--    * watcher: The watcher object being created.
--    * userData: The userData you included, if any.
--  * an optional userData object which will be included as the final argument to the callback function when it is called.
--
-- Returns:
--  * An `hs.uielement.watcher` object, or `nil` if an error occurred
function M:newWatcher(handler, userData, ...) end

-- Returns the role of the element.
--
-- Parameters:
--  * None
--
-- Returns:
--  * A string containing the role of the UI element
---@return string
function M:role() end

-- Returns the selected text in the element
--
-- Parameters:
--  * None
--
-- Returns:
--  * A string containing the selected text, or nil if none could be found
--
-- Notes:
--  * Many applications (e.g. Safari, Mail, Firefox) do not implement the necessary accessibility features for this to work in their web views
function M:selectedText() end

-- Watch for events on certain UI elements (including windows and applications)
--
-- You can watch the following events:
-- ### Application-level events
-- See hs.application.watcher for more events you can watch.
-- * hs.uielement.watcher.applicationActivated: The current application switched to this one.
-- * hs.uielement.watcher.applicationDeactivated: The current application is no longer this one.
-- * hs.uielement.watcher.applicationHidden: The application was hidden.
-- * hs.uielement.watcher.applicationShown: The application was shown.
--
-- #### Focus change events
-- These events are watched on the application level, but send the relevant child element to the handler.
-- * hs.uielement.watcher.mainWindowChanged: The main window of the application was changed.
-- * hs.uielement.watcher.focusedWindowChanged: The focused window of the application was changed. Note that the application may not be activated itself.
-- * hs.uielement.watcher.focusedElementChanged: The focused UI element of the application was changed.
--
-- ### Window-level events
-- * hs.uielement.watcher.windowCreated: A window was created. You should watch for this event on the application, or the parent window.
-- * hs.uielement.watcher.windowMoved: The window was moved.
-- * hs.uielement.watcher.windowResized: The window was resized.
-- * hs.uielement.watcher.windowMinimized: The window was minimized.
-- * hs.uielement.watcher.windowUnminimized: The window was unminimized.
--
-- ### Element-level events
-- These work on all UI elements, including windows.
-- * hs.uielement.watcher.elementDestroyed: The element was destroyed.
-- * hs.uielement.watcher.titleChanged: The element's title was changed.
---@type hs.uielement.watcher
M.watcher = nil
