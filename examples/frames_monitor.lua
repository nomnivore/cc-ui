require("_path")

local UI = require("ccui")
local c = UI.Components

local monitor = assert(peripheral.wrap("top"), "attach a monitor on top first") --[[@as ccTweaked.peripherals.Monitor]]
monitor.setTextScale(0.5)

local app = UI.new(monitor)

app.root:setProps("bgColor", colors.green)

app.root:add(c.Frame.new({
	x = 3,
	y = 3,
	width = 4,
	height = 2,
	bgColor = colors.lightBlue,
}))

app:addEventListener("char", function(key)
	if key == "q" then
		app:stop()
	end
end)

app:start()
