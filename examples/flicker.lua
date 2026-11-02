require("_path")

local UI = require("ccui")
local c = UI.Components

local INTERVAL = 0.05 -- one game tick

local app = UI.new()
local width = app.root:getProp("width")
local height = app.root:getProp("height")
local frames = 0

app.root:setProp("bgColor", colors.blue)

-- a large block of contrasting colour, so tearing between layers is easy to spot
app.root:add(c.Frame.new({
	x = 2,
	y = 2,
	width = width - 2,
	height = height - 3,
	bgColor = colors.gray,
}))

-- every row's content changes each frame, so every cell gets rewritten
for row = 3, height - 3 do
	app.root:add(c.Label.new({
		x = 3,
		y = row,
		bgColor = colors.gray,
		fgColor = row % 2 == 0 and colors.yellow or colors.lime,
		text = function()
			return string.rep(tostring((frames + row) % 10), width - 4)
		end,
	}))
end

app.root:add(c.Label.new({
	x = 2,
	y = height,
	text = function()
		return ("frame %d  clock %.2f  (q to quit)"):format(frames, os.clock())
	end,
}))

-- timer chain: each tick schedules the next, and every event triggers a redraw
local timerId = os.startTimer(INTERVAL)
app:addEventListener("timer", function(id)
	if id == timerId then
		frames = frames + 1
		timerId = os.startTimer(INTERVAL)
	end
end)

app:addEventListener("char", function(key)
	if key == "q" then
		app:stop()
	end
end)

app:start()
