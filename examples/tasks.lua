require("_path")

-- Throwaway test for step 6 (tasks). What to look for:
--   clock    ticks every second, with no input       (every, created before start())
--   worker   counts up every 0.5s                    (spawn + sleep)
--   key      shows the last key pressed, and keeps working while timers fire
--            (a task waiting on a filter must survive events it didn't ask for)
--   nested   reads "parent, child" immediately      (a task spawning a task during its first run)
--   ticker   "Stop ticker" freezes it, press again to restart (cancel an every)
--   outside  counts from OUTSIDE the app (parallel); 'i' toggles invalidate
--            off -> the number can lag until some other event arrives
--            (stop the ticker first, fewer events = easier to see)
--   job      "Start job" runs 10 steps; clicking it again while running does nothing
--            "Cancel" stops it partway                (spawn from a handler + cancel)
--   toast    "Toast" shows a message that clears 2s later; clicking again restarts it
--            (after from a handler + cancelling an after)
--   e        spawns a task that errors -> app exits, prints "tasks.lua:<line>: boom from a task"
--   q        quit

local ui = require("ccui")

local app = ui.App()

-- state, as plain locals
local now = "--:--:--"
local worker = 0
local lastKey = "-"
local nested = {}
local ticks = 0
local stopTicker = nil
local outside = 0
local useInvalidate = true
local job = { progress = nil, cancel = nil }
local toast = nil
local cancelToast = nil

local function row(y, fn)
	app:add(ui.Label({ x = 2, y = y, text = fn }))
end

app:add(ui.Label({ x = 2, y = 1, text = "tasks.lua   q quit   e error   i invalidate", fgColor = colors.lightGray }))

-- clock: every, registered before start()
app:every(1, function()
	now = os.date("%H:%M:%S")
end)
row(3, function()
	return "clock    " .. now
end)

-- worker: a plain long-running task
app:spawn(function()
	while true do
		sleep(0.5)
		worker = worker + 1
	end
end)
row(4, function()
	return "worker   " .. worker
end)

-- key: a task with an event filter
app:spawn(function()
	while true do
		local _, key = os.pullEvent("key")
		lastKey = keys.getName(key) or tostring(key)
	end
end)
row(5, function()
	return "key      " .. lastKey
end)

-- nested: the child is spawned during the parent's first run
app:spawn(function()
	table.insert(nested, "parent")
	app:spawn(function()
		table.insert(nested, "child")
	end)
end)
row(6, function()
	return "nested   " .. table.concat(nested, ", ")
end)

-- ticker: a cancellable every
local function startTicker()
	stopTicker = app:every(0.2, function()
		ticks = ticks + 1
	end)
end
startTicker()
row(7, function()
	return "ticker   " .. ticks .. (stopTicker and "" or "  (stopped)")
end)

-- outside: updated by a coroutine the app's scheduler knows nothing about
row(8, function()
	return "outside  " .. outside .. "  (invalidate " .. (useInvalidate and "on" or "off") .. ")"
end)

-- job: spawned from a click, reports progress, can be cancelled
local JOB_STEPS = 10
app:add(ui.ProgressBar({
	x = 10,
	y = 10,
	value = function()
		return job.progress
	end,
	max = JOB_STEPS,
	text = function()
		local p = job.progress
		if p == nil then
			return "idle"
		elseif type(p) == "string" then
			return p
		end
		return "running"
	end,
}))

app:add(ui.Button({
	x = 2,
	y = 11,
	text = "Start job",
	bgColor = colors.green,
	fgColor = colors.white,
	onClick = function()
		if job.cancel then
			return -- already running
		end
		job.progress = 0
		job.cancel = app:spawn(function()
			for i = 1, JOB_STEPS do
				sleep(0.3)
				job.progress = i
			end
			job.progress = "done"
			job.cancel = nil
		end)
	end,
}))

app:add(ui.Button({
	x = 14,
	y = 11,
	text = "Cancel",
	bgColor = colors.red,
	fgColor = colors.white,
	onClick = function()
		if job.cancel then
			job.cancel()
			job.cancel = nil
			job.progress = "cancelled"
		end
	end,
}))

-- toast: after from a click; clicking again cancels the old timer
app:add(ui.Button({
	x = 2,
	y = 13,
	text = "Toast",
	onClick = function()
		if cancelToast then
			cancelToast()
		end
		toast = "hello at " .. os.date("%H:%M:%S")
		cancelToast = app:after(2, function()
			toast = nil
			cancelToast = nil
		end)
	end,
}))
app:add(ui.Label({
	x = 10,
	y = 13,
	text = function()
		return toast or ""
	end,
	fgColor = colors.yellow,
}))

app:add(ui.Button({
	x = 2,
	y = 15,
	text = function()
		return stopTicker and "Stop ticker" or "Start ticker"
	end,
	onClick = function()
		if stopTicker then
			stopTicker()
			stopTicker = nil
		else
			startTicker()
		end
	end,
}))

app:addEventListener("char", function(key)
	if key == "q" then
		app:stop()
	elseif key == "i" then
		useInvalidate = not useInvalidate
	elseif key == "e" then
		app:spawn(function()
			sleep(0.5)
			error("boom from a task")
		end)
	end
end)

-- the app is listed first, so on a shared timer event it redraws BEFORE
-- the outside coroutine updates; only invalidate makes the change show
parallel.waitForAny(function()
	app:start()
end, function()
	while true do
		sleep(1.5)
		outside = outside + 1
		if useInvalidate then
			app:invalidate()
		end
	end
end)
