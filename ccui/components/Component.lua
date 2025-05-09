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
