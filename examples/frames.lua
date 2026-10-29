require("_path")

local UI = require("ccui")
local c = UI.Components

local app = UI.new()

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
