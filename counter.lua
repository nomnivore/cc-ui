-- Simple counter example app using ccui

local UI = require("ccui")
local c = UI.Components

local app = UI.new()

local function centeredHorizontally(self)
	return math.floor((self.parent:getProps("width") - self:getProps("width")) / 2)
end

app.root
	:add(c.Label.new({
		text = "Counter",
		x = centeredHorizontally,
		y = 1,
	}))
	:add(c.Label.new({
		text = "0",
		x = centeredHorizontally,
		y = 2,
		id = "count",
	}))
	:add(c.Button
		.new({
			text = "Increment",
			x = function(self)
				return centeredHorizontally(self) - 6
			end,
			y = 3,
			bgColor = colors.green,
			fgColor = colors.white,
		})
		:onClick(function()
			app.root:findById("count").props.text = tostring(tonumber(app.root:findById("count"):getProps("text")) + 1)
		end))
	:add(c.Button
		.new({
			text = "Decrement",
			x = function(self)
				return centeredHorizontally(self) + 6
			end,
			y = 3,
			bgColor = colors.red,
			fgColor = colors.white,
		})
		:onClick(function()
			app.root:findById("count").props.text = tostring(tonumber(app.root:findById("count"):getProps("text")) - 1)
		end))
	:add(c.Button
		.new({
			text = "Exit Program",
			x = centeredHorizontally,
			y = app.root:getProps("height") - 1,
		})
		:onClick(function()
			app:stop()
		end))
	:add(c.Label.new({
		text = "'k' to increment, 'j' to decrement, 'q' to quit",
		x = centeredHorizontally,
		y = app.root:getProps("height"),
	}))

app:addEventListener("char", function(key)
	if key == "q" then
		app:stop()
	end
end)

app:addEventListener("key", function(key)
	local countComponent = app.root:findById("count")
	if countComponent == nil then
		return
	end
	---@cast countComponent Label
	if key == keys.j then
		countComponent.props.text = tostring(tonumber(countComponent:getProps("text")) - 1)
	elseif key == keys.k then
		countComponent.props.text = tostring(tonumber(countComponent:getProps("text")) + 1)
	end
end)

app:start()
