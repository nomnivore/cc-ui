local Frame = require("ccui.components.Frame")

---@alias EventFn fun(...)

---@class App
---@field root Frame
---@field term ccTweaked.term.Redirect
---@field running boolean
---@field monitorName string?
---@field private events table<ccTweaked.os.event, EventFn[]>
---@field private buffer ccTweaked.Window
local App = {}
App.__index = App

---@class AppOptions
---@field term ccTweaked.term.Redirect?

---@return App
---@param opts AppOptions?
function App.new(opts)
	local self = setmetatable({}, App)
	opts = opts or {}

	self.term = opts.term or term.current()

	-- check if monitor
	local ok, name = pcall(peripheral.getName, self.term)
	self.monitorName = ok and name or nil

	self.root = Frame.new({
		term = self.term,
		-- inherited properties found in ./components/Component.lua
		-- should have defaults defined here
		bgColor = colors.black,
		fgColor = colors.white,
	})
	self.running = false
	self.events = {}
	local w, h = self.term.getSize()
	self.buffer = window.create(self.term, 1, 1, w, h, false)

	return self
end

function App:clearScreen()
	self.term.setTextColor(colors.white)
	self.term.setBackgroundColor(colors.black)
	self.term.clear()
	self.term.setCursorPos(1, 1)
end

function App:renderUI()
	self.buffer.setVisible(false)
	-- resize the buffer, if needed
	local rootW, rootH = self.root:getSize()
	local bufW, bufH = self.buffer.getSize()
	if rootW ~= bufW or rootH ~= bufH then
		self.buffer.reposition(1, 1, rootW, rootH)
	end

	self.root:render(self.buffer)
	self.buffer.setVisible(true)
end

---Adds an event listener to the app, which will now be checked for in the main event loop.
---Returns the app and the callback function, which can be used to remove the listener.
---@param event string
---@param callback EventFn
---@return App, EventFn
function App:addEventListener(event, callback)
	if not self.events[event] then
		self.events[event] = {}
	end
	table.insert(self.events[event], callback)

	return self, callback
end

---Removes an event listener from the app
---@param event string
---@param callback EventFn
---@return App
function App:removeEventListener(event, callback)
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

-- Private functions for the :start loop

--- Broadcasts an OS event to all app eventListeners
---@param eventData table
---@private
function App:broadcast(eventData)
	local event = eventData[1]
	if self.events[event] then
		for _, callback in ipairs(self.events[event]) do
			callback(table.unpack(eventData, 2, eventData.n))
		end
	end
end

local MOUSE_BUTTONS = { [1] = "click", [2] = "rightClick" }

--- Translates an OS event to UI event data
---@param eventData table
---@return UIEventData|nil e WITHOUT a 'target' set
---@private
function App:translate(eventData)
	local event = eventData[1]
	local name, button

	if event == "mouse_click" and not self.monitorName then
		button = eventData[2]
		name = MOUSE_BUTTONS[button]
	elseif event == "monitor_touch" and eventData[2] == self.monitorName then
		button = 1
		name = MOUSE_BUTTONS[button]
	end

	if not name then
		return nil
	end

	return {
		name = name,
		button = button,
		x = eventData[3],
		y = eventData[4],
	}
end

---@param e UIEventData
---@private
function App:dispatch(e)
	local target = self.root:findTarget(e.x, e.y)
	if not target then
		return
	end

	e.target = target

	local bubbling = target
	while bubbling ~= nil do
		local stop = bubbling:emit(e.name, e)
		if stop then
			break
		end
		bubbling = bubbling.parent
	end
end

---Mounts the root component and starts the main event loop
---@return App
function App:start()
	-- normalize the terminal colors and content
	self:clearScreen()

	self.root:mount(self)

	self.running = true
	local ok, err = pcall(function()
		while self.running do
			self:renderUI()
			-- pullEventRaw catches "terminate" event for ctrl+T
			-- if we want apps to be able to intercept it.
			-- NOT implemented yet. ctrl+T uses normal behaviour.
			local eventData = table.pack(os.pullEvent())
			self:broadcast(eventData)
			local uiEvent = self:translate(eventData)
			if uiEvent then
				self:dispatch(uiEvent)
			end
		end
	end)
	self.running = false
	self:clearScreen()
	-- rethrow errors after cleanup
	if not ok then
		error(err, 0)
	end

	return self
end

---Stops the main event loop and unmounts the root component
---@return App
function App:stop()
	self.running = false

	return self
end

return App
