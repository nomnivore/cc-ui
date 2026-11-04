local Frame = require("ccui.components.Frame")
local util = require("ccui.util")

---@alias EventFn fun(...)

---@class App
---@overload fun(opts: AppOptions?): App
---@field root Frame
---@field term ccTweaked.term.Redirect
---@field running boolean
---@field monitorName string?
---@field private events table<ccTweaked.os.event, EventFn[]>
---@field private buffer ccTweaked.Window
---@field private tasks TaskRecord[]
---@field private pendingTasks TaskRecord[]
local App = util.class()

---@class AppOptions
---@field term ccTweaked.term.Redirect?
---@field [integer] Component|false

---@class TaskRecord
---@field co thread
---@field filter string|nil
---@field cancelled boolean|nil

---@return App
---@param opts AppOptions?
function App.new(opts)
	local self = setmetatable({}, App --[[@as table]])
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

	self.tasks = {}
	self.pendingTasks = {}

	local w, h = self.term.getSize()
	self.buffer = window.create(self.term, 1, 1, w, h, false)

	-- add children from positional arguments
	for _, v in ipairs(opts) do
		if type(v) == "table" and v.mount then
			self:add(v)
		end
	end

	return self
end

---Adds a component to the root
---@param child Component
---@return App self
function App:add(child)
	self.root:add(child)

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

-- Concurrency / Scheduler methods

---Runs `fn` as a background task, which may sleep or pullEvent without blocking the app.
---@param fn function
---@return function cancel
function App:spawn(fn)
	---@type TaskRecord
	local record = { co = coroutine.create(fn) }
	table.insert(self.pendingTasks, record)

	return function()
		record.cancelled = true
	end
end

---Runs `fn` after `s` seconds.
---@param fn function
---@return function cancel
function App:after(s, fn)
	return self:spawn(function()
		sleep(s)
		fn()
	end)
end

---Runs `fn` once, then again every `s` seconds indefinitely until cancelled.
---@param fn function
---@return function cancel
function App:every(s, fn)
	return self:spawn(function()
		fn()
		while true do
			-- indefinite until cancelled
			sleep(s)
			fn()
		end
	end)
end

---Loop over App.tasks to resume eligible tasks
---adding them to a fresh list if they are not dead.
---@param eventData table
---@return table survivingTasks
---@private
function App:resumeTasks(eventData)
	local survivingTasks = {}
	for _, v in ipairs(self.tasks) do
		if not v.cancelled then
			if v.filter == nil or v.filter == eventData[1] or eventData[1] == "terminate" then
				local ok, newFilter = coroutine.resume(v.co, table.unpack(eventData, 1, eventData.n))
				if not ok then
					error(newFilter, 0)
				end
				v.filter = newFilter
			end
			if coroutine.status(v.co) ~= "dead" then
				table.insert(survivingTasks, v)
			end
		end
	end

	return survivingTasks
end

---Loop over App.pendingTasks to drain and start all tasks
---adding them to App.tasks if they are not dead.
---@private
function App:startPendingTasks()
	for _, v in ipairs(self.pendingTasks) do
		if not v.cancelled then
			local ok, filter = coroutine.resume(v.co)
			if not ok then
				error(filter, 0)
			end
			v.filter = filter
			if coroutine.status(v.co) ~= "dead" then
				table.insert(self.tasks, v)
			end
		end
	end

	self.pendingTasks = {}
end

-- Private functions for the :start loop

---Broadcasts an OS event to all app eventListeners
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

---Translates an OS event to UI event data
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

-- App lifecycle pieces: managed in App:start
-- Accessible to end-users that want to control the event loop themselves.

---Mounts the root component to the screen and performs a first-render.
---For advanced control flow.
---@see App.start for normal control.
function App:open()
	-- normalize the terminal colors and content
	self:clearScreen()

	self.root:mount(self)

	self.running = true

	self:startPendingTasks()

	self:renderUI()
end

---Updates the app with an event (from os.pullEvent) and re-render.
---For advanced control flow.
---@see App.start for normal control.
function App:update(...)
	local eventData = table.pack(...)

	-- guard: if the user passed in an pre-packed table, just use that
	-- first element should always be a string, so we can check for table
	if type(eventData[1]) == "table" then
		eventData = eventData[1]
	end

	-- resume ongoing tasks
	self.tasks = self:resumeTasks(eventData)

	-- handle main-thread events
	self:broadcast(eventData)
	local uiEvent = self:translate(eventData)
	if uiEvent then
		self:dispatch(uiEvent)
	end

	-- start new tasks
	self:startPendingTasks()

	self:renderUI()
end

---Unmounts the root component and gracefully shuts down the application.
---For advanced control flow.
---@see App.start for normal control.
---@see App.stop for normal control.
function App:close()
	self.running = false -- may be redundant but just to be sure
	self:clearScreen()
	self.root:unmount()
end

---Sends a redraw event to the application
function App:invalidate()
	-- TODO: set/unset a flag so that 10 invalidate calls
	-- result in just one event
	os.queueEvent("ccui_redraw")
end

---Mounts the app along with a controlled main event loop and error handling.
---@return App
function App:start()
	self:open()

	local ok, err = pcall(function()
		while self.running do
			-- pullEventRaw catches "terminate" event for ctrl+T
			-- if we want apps to be able to intercept it.
			-- NOT implemented yet. ctrl+T uses normal behaviour.
			self:update(os.pullEvent())
		end
	end)

	self:close()
	-- rethrow errors after cleanup
	if not ok then
		error(err, 0)
	end

	return self
end

---Stops the main event loop and unmounts the application
---@return App
function App:stop()
	self.running = false

	return self
end

return App
