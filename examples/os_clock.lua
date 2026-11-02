require("_path")

local UI = require("ccui")
local c = UI.Components

local app = UI.new()

-- app.root:setProp("bgColor", colors.green)

app.root:add(c.Label.new({
	text = function()
		return os.clock()
	end,
}))

app.root:add(c.Button.new({
	y = 4,
	-- bgColor = function()
	-- 	return nil
	-- end,
	bgColor = colors.red,
	text = "my button",
}))

app:addEventListener("char", function(key)
	if key == "q" then
		app:stop()
	end
end)

app:start()
