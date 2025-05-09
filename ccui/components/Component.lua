local Util = require("ccui.util")

---@class Component
---@field type string
---@field x number
---@field y number
---@field width number
---@field height number
---@field bgColor ccTweaked.colors.color?
---@field fgColor ccTweaked.colors.color?
---@field parent Component?
---@field children Component[]
---@field core Core?
---@field eventListeners table<string, table<string, EventFn>>
local Component = {}
Component.__index = Component

---@class ComponentProps
---@field type string?
---@field x number?
---@field y number?
---@field width number?
---@field height number?
---@field bgColor ccTweaked.colors.color?
---@field fgColor ccTweaked.colors.color?

--- Creates a new component
---@param props ComponentProps
function Component.new(props)
  local self = setmetatable({}, Component)

  -- props with default values
  self.type = "component"
  self.x = 1
  self.y = 1
  self.width = 1
  self.height = 1

  -- props defined in table arg
  for k, v in pairs(props) do
    self[k] = v
  end

  self.parent = nil
  self.children = {}
  self.eventListeners = {}


  return self
end

--- Adds a child component to this component, mounting it if this component is mounted
---@param child Component
function Component:add(child)
  child.parent = self
  table.insert(self.children, child)

  if self.core then
    child:mount(self.core)
  end

  return self
end

-- Event handling

--- Mounts this component and all children to a core, adding its event listeners
---@param core Core
function Component:mount(core)
  self.core = core

  if self.eventListeners then
    for event, listeners in pairs(self.eventListeners) do
      for _, listener in ipairs(listeners) do
        core:addEventListener(event, listener)
      end
    end
  end

  for _, child in ipairs(self.children) do
    child:mount(core)
  end
end

--- Unmounts this component and all children from the core, removing its event listeners
function Component:unmount()
  if self.core and self.eventListeners then
    for event, listeners in pairs(self.eventListeners) do
      for _, listener in ipairs(listeners) do
        self.core:removeEventListener(event, listener)
      end
    end
  end

  for _, child in ipairs(self.children) do
    child:unmount()
  end

  self.core = nil
end

--- Adds an event listener to the component
---@param event ccTweaked.os.event
---@param callback EventFn
---@return Component, EventFn
function Component:on(event, callback)
  if not self.eventListeners[event] then
    self.eventListeners[event] = {}
  end

  local listener = function(...)
    callback(self, ...)
  end

  table.insert(self.eventListeners[event], listener)

  return self, listener
end

--- Removes an event listener from the component
---@param event ccTweaked.os.event
---@param callback EventFn
---@return Component
function Component:off(event, callback)
  if not self.eventListeners[event] then
    return self
  end

  for i, v in ipairs(self.eventListeners[event]) do
    if v == callback then
      table.remove(self.eventListeners[event], i)
      break
    end
  end

  return self
end

--- Tests if a point is inside the component's bounds
---@param x number
---@param y number
---@return boolean
function Component:hitTest(x, y)
  return Util.pointInRect(x, y, self)
end

--- Adds an event listener for mouse clicks on the component
---@param callback fun(self: Component)
---@return Component
function Component:onClick(callback)
  self:on("mouse_click", function(_, mb, x, y)
    if mb == 1 and self:hitTest(x, y) then
      callback(self)
    end
  end)

  return self
end

--- Renders the component to the display
---@param term ccTweaked.term.Redirect
function Component:render(term)
  if self.x and self.y then
    term.setCursorPos(self.x, self.y)
  end

  for _, child in ipairs(self.children) do
    if self.bgColor then
      term.setBackgroundColor(self.bgColor)
    end
    if self.fgColor then
      term.setTextColor(self.fgColor)
    end
    child:render(term)
  end
end

return Component