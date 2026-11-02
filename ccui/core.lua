local Frame = require("ccui.components.Frame")

---@alias EventFn fun(...)

---@class Core
---@field root Frame
---@field term ccTweaked.term.Redirect
---@field running boolean
---@field private events table<ccTweaked.os.event, EventFn[]>
---@field private buffer ccTweaked.Window
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

function Core:clearScreen()
	self.term.setTextColor(colors.white)
	self.term.setBackgroundColor(colors.black)
	self.term.clear()
	self.term.setCursorPos(1, 1)
end

function Core:renderUI()
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

-- Private functions for the :start loop

--- Broadcasts an OS event to all app eventListeners
---@param eventData table
---@private
function Core:broadcast(eventData)
	local event = eventData[1]
	if self.events[event] then
		for _, callback in ipairs(self.events[event]) do
			callback(table.unpack(eventData, 2, eventData.n))
		end
	end
end

--- Translates an OS event to a UI event tag
---@param eventData table
---@return UIEventData|nil e WITHOUT a 'target' set (maybe needs type annotation fixing?)
---@private
function Core:translate(eventData)
	local event = eventData[1]
	if event == "mouse_click" then
		local button = eventData[2]
		if button == 1 then
			return {
				name = "click",
				button = button,
				x = eventData[3],
				y = eventData[4],
			}
		elseif button == 2 then
			return {
				name = "rightClick",
				button = button,
				x = eventData[3],
				y = eventData[4],
			}
		end
	end
end

---@param e UIEventData
---@private
function Core:dispatch(e)
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
---@return Core
function Core:start()
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
---@return Core
function Core:stop()
	self.running = false

	return self
end

return Core
