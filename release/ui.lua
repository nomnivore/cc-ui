-- Bundled by luabundle {"version":"1.7.0"}
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("__root", function(require, _LOADED, __bundle_register, __bundle_modules)
local exports = {
  Core = require("ccui.core"),
  Components = require("ccui.components"),
  Util = require("ccui.util"),

  new = require("ccui.core").new,
}

return exports

-- To bundle, run:
-- bunx luabundler bundle .\ccui\init.lua -p "?.lua" -p "?\\init.lua" -o release/ccui.lua
-- (requires bun to be installed (or npm with npx))
end)
__bundle_register("ccui.core", function(require, _LOADED, __bundle_register, __bundle_modules)
local Component = require("ccui.components.Component")
local Frame = require("ccui.components.Frame")
local Util = require("ccui.util")

---@alias EventFn fun(self: Component, ...)

---@class Core
---@field root Frame
---@field term ccTweaked.term.Redirect
---@field running boolean
---@field private events table<ccTweaked.os.event, EventFn[]>
local Core = {}
Core.__index = Core

-- used to hang onto the global term object
local ccterm = term


---@return Core
---@param term ccTweaked.term.Redirect?
function Core.new(term)
  local self = setmetatable({}, Core)

  self.term = term or ccterm.current()
  self.root = Frame.new({
    term = self.term,
  })
  self.running = false
  self.events = {}
  
  local test = self.events["alarm"]

  return self
end

function Core:clearScreen()
  self.term.clear()
  self.term.setCursorPos(1, 1)
  self.term.setTextColor(colors.white)
  self.term.setBackgroundColor(colors.black)
end

function Core:renderUI()
  self:clearScreen()
  self.root:render(self.term)
end

---Adds an event listener to the core, which will now be checked for in the main event loop.
---Returns the core and the callback function, which can be used to remove the listener.
---@param event string
---@param callback EventFn
---@return Core, EventFn
function Core:addEventListener(event, callback)
  if not self.events[event] then
    self.events[event] = {}
  end
  table.insert(self.events[event], callback)

  return self, callback
end

---Removes an event listener from the core
---@param event string
---@param callback EventFn
---@return Core
function Core:removeEventListener(event, callback)
  if not self.events[event] then
    return self
  end

  for i, v in ipairs(self.events[event]) do
    if v == callback then
      table.remove(self.events[event], i)
      break
    end
  end

  return self
end

---Mounts the root component and starts the main event loop
---@return Core
function Core:start()
  -- first render
  self.root:mount(self)
  self:renderUI()

  self.running = true
  while self.running do
    self:renderUI()
    local event, param1, param2, param3 = os.pullEvent()
    if self.events[event] then
      for _, callback in ipairs(self.events[event]) do
        callback(param1, param2, param3)
      end
    end

    -- if event == "char" then
    --   if param1 == "q" then
    --     self:stop()
    --   end
    -- end
  end
  self:clearScreen()

  return self
end

---Stops the main event loop and unmounts the root component
---@return Core
function Core:stop()
  self.running = false

  return self
end

return Core
end)
__bundle_register("ccui.util", function(require, _LOADED, __bundle_register, __bundle_modules)
local Util = {}

local id = 0
function Util.generateUniqueId()
  id = id + 1
  return id
end

---@alias Rect {x: number, y: number, width: number, height: number}

--- Checks if a point is inside a rectangle
---@param x number
---@param y number
---@param rect Rect
---@return boolean
function Util.pointInRect(x, y, rect)
  return x >= rect.x and x <= rect.x + rect.width - 1 and y >= rect.y and y <= rect.y + rect.height - 1
end

return Util
end)
__bundle_register("ccui.components.Frame", function(require, _LOADED, __bundle_register, __bundle_modules)
local Component = require("ccui.components.Component")

---@class FrameProps : ComponentProps
---@field term ccTweaked.term.Redirect

---@class Frame : Component
---@field props FrameProps
local Frame = {}
setmetatable(Frame, Component)
Frame.__index = Frame

---@class NewFrameProps : NewComponentProps
---@field term ccTweaked.term.Redirect?

--- Creates a new frame component, which is a container for other components.
--- Also acts as a root component for an app.
--- Defaults to the size of the terminal if no width/height are specified.
---@param props NewFrameProps
function Frame.new(props)
  local self = Component.new(props)
  setmetatable(self, Frame)
  ---@cast self Frame

  local tW, tH = term.getSize()

  self.props.type = "frame"

  self.props.x = props.x or 1
  self.props.y = props.y or 1
  self.props.width = props.width or tW
  self.props.height = props.height or tH

  return self
end

---@param term ccTweaked.term.Redirect
function Frame:render(term)
  local x = self:getProps("x")
  local y = self:getProps("y")
  local bgColor = self:getProps("bgColor")
  local fgColor = self:getProps("fgColor")
  local width = self:getProps("width")
  local height = self:getProps("height")

  term.setCursorPos(x, y)
  if bgColor then
    term.setBackgroundColor(bgColor)
  end
  if fgColor then
    term.setTextColor(fgColor)
  end

  -- print entire width/height using bg color
  for i = 1, height do
    term.write(string.rep(" ", width))
  end

  -- reset cursor position
  term.setCursorPos(x, y)

  -- render children
  Component.render(self, term)
end

return Frame
end)
__bundle_register("ccui.components.Component", function(require, _LOADED, __bundle_register, __bundle_modules)
local Util = require("ccui.util")

---@class ComponentProps
---@field type string|fun(self: Component): string
---@field x number|fun(self: Component): number
---@field y number|fun(self: Component): number
---@field width number|fun(self: Component): number
---@field height number|fun(self: Component): number
---@field bgColor ccTweaked.colors.color|nil|fun(self: Component): ccTweaked.colors.color
---@field fgColor ccTweaked.colors.color|nil|fun(self: Component): ccTweaked.colors.color
---@field id string

---@class Component
---@field parent Component?
---@field children Component[]
---@field core Core?
---@field eventListeners table<string, table<string, EventFn>>
---@field props ComponentProps @see getProps
local Component = {}
Component.__index = Component

---@class NewComponentProps
---@field type string|nil|fun(self: Component): string
---@field x number|nil|fun(self: Component): number
---@field y number|nil|fun(self: Component): number
---@field width number|nil|fun(self: Component): number
---@field height number|nil|fun(self: Component): number
---@field bgColor ccTweaked.colors.color|nil|fun(self: Component): ccTweaked.colors.color
---@field fgColor ccTweaked.colors.color|nil|fun(self: Component): ccTweaked.colors.color
---@field id string|nil

--- Creates a new component
---@param props NewComponentProps
function Component.new(props)
  local self = setmetatable({}, Component)

  -- props with default values
---@diagnostic disable-next-line: missing-fields
  self.props = {}
  self.props.type = "component"
  self.props.x = 1
  self.props.y = 1
  self.props.width = 1
  self.props.height = 1

  -- props defined in table arg
  for k, v in pairs(props) do
    self.props[k] = v
  end

  if props.id == nil then
    self.props.id = tostring(Util.generateUniqueId())
  end

  self.parent = nil
  self.children = {}
  self.eventListeners = {}


  return self
end

--- Finds a component by its id
---@param id string
---@return Component?
function Component:findById(id)
  if self:getProps("id") == id then
    return self
  end

  for _, child in ipairs(self.children) do
    local result = child:findById(id)
    if result then
      return result
    end
  end
end

--- Gets a prop value, evaluating functions if necessary
---@param name string
---@param defaultValue any?
---@return any
function Component:getProps(name, defaultValue)
  local value = self.props[name]
  if type(value) == "function" then
      return value(self)
  elseif value == nil then
      return defaultValue
  else
      return value
  end
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
  return Util.pointInRect(x, y, {
    x = self:getProps("x"),
    y = self:getProps("y"),
    width = self:getProps("width"),
    height = self:getProps("height"),
  })
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
  local x = self:getProps("x")
  local y = self:getProps("y")
  local bgColor = self:getProps("bgColor")
  local fgColor = self:getProps("fgColor")

  if x and y then
    term.setCursorPos(x, y)
  end

  for _, child in ipairs(self.children) do
    if bgColor then
      term.setBackgroundColor(bgColor)
    end
    if fgColor then
      term.setTextColor(fgColor)
    end
    child:render(term)
  end
end

return Component
end)
__bundle_register("ccui.components", function(require, _LOADED, __bundle_register, __bundle_modules)
local exports = {
    Component = require("ccui.components.Component"),
    Frame = require("ccui.components.Frame"),
    Label = require("ccui.components.Label"),
    Button = require("ccui.components.Button"),
}

return exports
end)
__bundle_register("ccui.components.Button", function(require, _LOADED, __bundle_register, __bundle_modules)
local Component = require("ccui.components.Component")

---@class ButtonProps : ComponentProps
---@field text string|fun(self: Button): string

---@class Button : Component
---@field props ButtonProps
local Button = {}
setmetatable(Button, Component)
Button.__index = Button

---@class NewButtonProps : NewComponentProps
---@field text string|nil|fun(self: Button): string

---@param props NewButtonProps
function Button.new(props)
  local self = Component.new(props)
  setmetatable(self, Button)
  ---@cast self Button
  
  self.props.type = "button"
  self.props.text = props.text or ""
  self.props.width = props.width or function(self) return #self:getProps("text") + 2 end
  self.props.height = props.height or 1

  return self
end

---@param term ccTweaked.term.Redirect
function Button:render(term)
  local bg = self:getProps("bgColor", colors.white)
  local fg = self:getProps("fgColor", colors.black)
  local x = self:getProps("x")
  local y = self:getProps("y")
  local width = self:getProps("width")
  local height = self:getProps("height")
  local text = self:getProps("text")

  local labelY = y + math.floor((height - 1) / 2)

  term.setBackgroundColor(bg)
  term.setTextColor(fg)

  term.setCursorPos(x, y)
  -- print entire width/height using bg color
  for i = 1, height do
    term.setCursorPos(x, y + i - 1)
    term.write(string.rep(" ", width))
  end

  term.setCursorPos(x + 1, labelY)
  term.write(text)

  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)

  Component.render(self, term)
end

return Button

end)
__bundle_register("ccui.components.Label", function(require, _LOADED, __bundle_register, __bundle_modules)
local Component = require("ccui.components.Component")

---@class LabelProps : ComponentProps
---@field text string|fun(self: Label): string

---@class Label : Component
---@field props LabelProps
local Label = {}
setmetatable(Label, Component)
Label.__index = Label

---@class NewLabelProps : NewComponentProps
---@field text string|nil|fun(self: Label): string

---@param props NewLabelProps
function Label.new(props)
  local self = Component.new(props)
  setmetatable(self, Label)
  ---@cast self Label

  self.props.type = "label"
  self.props.text = props.text or ""

  self.props.width = props.width or function(self) return #self:getProps("text") end
  return self
end

function Label:setText(text)
  self.props.text = text

  return self
end


---@param term ccTweaked.term.Redirect
function Label:render(term)
  local x = self:getProps("x")
  local y = self:getProps("y")
  local fg = self:getProps("fgColor", colors.white)
  local bg = self:getProps("bgColor", colors.black)
  local text = self:getProps("text")
  term.setCursorPos(x, y)
  term.blit(text, string.rep(colors.toBlit(fg), #text), string.rep(colors.toBlit(bg), #text))

  -- labels shouldn't have children anyway
  ---@todo remove
  Component.render(self, term)
end

return Label

end)
return __bundle_require("__root")