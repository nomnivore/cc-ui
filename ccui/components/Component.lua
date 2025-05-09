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

function Component:hitTest(x, y)
  return Util.pointInRect(x, y, self)
end

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