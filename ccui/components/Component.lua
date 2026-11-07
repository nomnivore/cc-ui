local util = require("ccui.util")

---@alias UIEventFn fun(self: Component, e: UIEventData): boolean?
---@alias UIEvent "click"|"rightClick"

---@class UIEventData
---@field name UIEvent
---@field x integer
---@field y integer
---@field target Component
---@field button integer

---@class ComponentProps
---@field type string|fun(self: Component): string
---@field x number|fun(self: Component): number
---@field y number|fun(self: Component): number
---@field width number|fun(self: Component): number|"fill"
---@field height number|fun(self: Component): number|"fill"
---@field bgColor ccTweaked.colors.color|nil|fun(self: Component): ccTweaked.colors.color
---@field fgColor ccTweaked.colors.color|nil|fun(self: Component): ccTweaked.colors.color
---@field id string

---@class Component
---@overload fun(props?: NewComponentProps): Component
---@field isContainer boolean?
---@field parent Component?
---@field children Component[]
---@field app App?
---@field handlers table<UIEvent, UIEventFn[]>
---@field props ComponentProps @see getProp
---@field state table<string, any>
---@field rect Rect?
local Component = util.class()

---@class NewComponentProps
---@field type string|nil|fun(self: Component): string
---@field x number|nil|fun(self: Component): number
---@field y number|nil|fun(self: Component): number
---@field width number|nil|fun(self: Component): number|"fill"
---@field height number|nil|fun(self: Component): number|"fill"
---@field bgColor ccTweaked.colors.color|nil|fun(self: Component): ccTweaked.colors.color
---@field fgColor ccTweaked.colors.color|nil|fun(self: Component): ccTweaked.colors.color
---@field id string|nil
---@field state table<string, any>|nil
---@field onClick UIEventFn|nil
---@field onRightClick UIEventFn|nil

local INHERITABLE_PROPS = {
	bgColor = true,
	fgColor = true,
}

--- Creates a new component
---@param props NewComponentProps?
---@param cls any? class to instantiate, default Component
---@return Component
function Component.new(props, cls)
	props = props or {}
	cls = cls or Component
	-- cast: @overload makes LuaLS see the class as callable, not a table
	local self = setmetatable({}, cls --[[@as table]])

	-- props with default values
	---@diagnostic disable-next-line: missing-fields
	self.props = {}
	self.props.type = "component"
	self.props.x = 1
	self.props.y = 1

	self.parent = nil
	self.children = {}
	self.handlers = {}

	-- props defined in table arg
	for k, v in pairs(props) do
		-- skip any keys that aren't strings
		if type(k) == "string" then
			-- UIEvent handlers: onX
			if string.match(k, "^on%u") and type(v) == "function" then
				local eventKey = string.sub(k, 3, 3):lower() .. string.sub(k, 4)
				self:on(eventKey, v)
			-- state goes to a different destination
			elseif k ~= "state" then
				self.props[k] = v
			end
		end
	end

	if props.state then
		for k, v in pairs(props.state) do
			self:setState(k, v)
		end
	end

	if props.id == nil then
		self.props.id = tostring(util.generateUniqueId())
	end

	if not cls.isContainer then
		-- throw an error if any positional arguments are passed in as components
		for _, v in ipairs(props) do
			if type(v) == "table" and v.mount then
				local name = (v.props and v.props.type or "unknown")
				error(
					"cannot add a '" .. name .. "' as a child: only container components accept children",
					3 -- should land in user code most of the time
				)
			end
		end
	end

	return self
end

---Returns the size the component would like to take, based on its content
---@return integer width, integer height
function Component:getPreferredSize()
	return 1, 1 -- an "empty" default that subclasses are meant to override
end

---Computes the size this component will take, given props and layout constraints
---@param availW integer available width
---@param availH integer available height
---@return integer width, integer height
function Component:measure(availW, availH)
	local prefW, prefH = self:getPreferredSize()

	local w = self:getProp("width", prefW)
	if w == "fill" then
		w = availW
	end

	local h = self:getProp("height", prefH)
	if h == "fill" then
		h = availH
	end

	return w, h
end

--- Finds a component by its id
---@param id string
---@return Component?
function Component:findById(id)
	if self:getProp("id") == id then
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
function Component:getProp(name, defaultValue)
	local value = self.props[name]
	if type(value) == "function" then
		value = value(self)
	end
	if value == nil then
		if INHERITABLE_PROPS[name] and self.parent then
			return self.parent:getProp(name, defaultValue)
		end
		return defaultValue
	else
		return value
	end
end

--- Sets a prop value
---@param name string
---@param value any
---@generic T: Component
---@param self T
---@return T
function Component:setProp(name, value)
	---@cast self Component
	self.props[name] = value

	return self
end

--- Gets the size of the component
---@return integer width
---@return integer height
function Component:getSize()
	-- return rect width/height, or 0,0 if nil
	if self.rect == nil then
		return 0, 0
	end

	return self.rect.width, self.rect.height
end

-- Event handling

--- Mounts this component and all children to an app
---@param app App
function Component:mount(app)
	self.app = app

	for _, child in ipairs(self.children) do
		child:mount(app)
	end
end

--- Unmounts this component and all children from the app
function Component:unmount()
	for _, child in ipairs(self.children) do
		child:unmount()
	end

	self.app = nil
end

--- Adds an event listener to the component
---@param event UIEvent
---@param callback UIEventFn
---@generic T: Component
---@param self T
---@return T
function Component:on(event, callback)
	---@cast self Component
	if not self.handlers[event] then
		self.handlers[event] = {}
	end

	table.insert(self.handlers[event], callback)

	return self
end

--- Removes an event listener from the component
---@param event UIEvent
---@param callback UIEventFn
---@generic T: Component
---@param self T
---@return T
function Component:off(event, callback)
	---@cast self Component
	if not self.handlers[event] then
		return self
	end

	for i, v in ipairs(self.handlers[event]) do
		if v == callback then
			table.remove(self.handlers[event], i)
			break
		end
	end

	return self
end

--- Attempts to fire a UI event on this component
---@param event UIEvent
---@param data UIEventData
---@return boolean handled whether this component handled/consumed the event, stopping propogation
function Component:emit(event, data)
	local handled = false
	-- check if there are any listeners
	if self.handlers[event] then
		for _, handler in ipairs(self.handlers[event]) do
			local result = handler(self, data)
			if result ~= false then
				handled = true
			end
		end
	end
	return handled
end

-- State management

--- Sets a state value
---@param key string
---@param value any
function Component:setState(key, value)
	if not self.state then
		self.state = {}
	end

	self.state[key] = value
end

--- Gets a state value
---@param key string
---@return any
function Component:getState(key)
	return self.state and self.state[key]
end

--- Get the component's absolute screen position
--- (x, y)
---@return number, number
function Component:getScreenPos()
	local x, y = 1, 1
	if self.rect ~= nil then
		x = self.rect.x
		y = self.rect.y
	end

	if self.parent then
		local pX, pY = self.parent:getScreenPos()
		return x + pX - 1, y + pY - 1
	end

	return x, y
end

--- Tests if a point is inside the component's bounds
---@param x number
---@param y number
---@return boolean
function Component:hitTest(x, y)
	if self.rect == nil then
		return false
	end

	local posX, posY = self:getScreenPos()
	local w, h = self:getSize()
	return util.pointInRect(x, y, {
		x = posX,
		y = posY,
		width = w,
		height = h,
	})
end

--- Finds the target component at the given coordinates
---@param x integer
---@param y integer
---@return Component?
function Component:findTarget(x, y)
	if self:hitTest(x, y) then
		return self
	end
end

--- Alias for :on("click", ...)
---@param callback UIEventFn
---@generic T: Component
---@param self T
---@return T
function Component:onClick(callback)
	---@cast self Component
	return self:on("click", callback)
end

---Stubbed for Components. Containers (Frames ->etc) compute rect sizes
function Component:layout() end

--- Render the component to the display
--- Empty by default
---@param term ccTweaked.term.Redirect
---@diagnostic disable-next-line: unused-local
function Component:render(term) end

return Component
