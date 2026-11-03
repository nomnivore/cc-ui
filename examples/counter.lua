require("_path")

-- Simple counter example app using ccui

local UI = require("ccui")

local app = UI.App()

local function centeredHorizontally(self)
	return math.floor((self.parent:getProp("width") - self:getProp("width")) / 2)
end

app.root
	:add(UI.Label({
		text = "Counter",
		x = centeredHorizontally,
		y = 1,
	}))
	:add(UI.Label({
		text = function(self)
			return self:getState("count")
		end,
		x = centeredHorizontally,
		y = 2,
		id = "count",
		state = {
			count = 0,
		},
	}))
	:add(UI.Button({
		text = "Increment",
		x = function(self)
			return centeredHorizontally(self) - 6
		end,
		y = 3,
		bgColor = colors.green,
		fgColor = colors.white,
	}):onClick(function()
		local el = app.root:findById("count")
		if not el then
			return
		end
		el:setState("count", el:getState("count") + 1)
	end))
	:add(UI.Button({
		text = "Decrement",
		x = function(self)
			return centeredHorizontally(self) + 6
		end,
		y = 3,
		bgColor = colors.red,
		fgColor = colors.white,
	}):onClick(function()
		local el = app.root:findById("count")
		if not el then
			return
		end
		el:setState("count", el:getState("count") - 1)
	end))
	:add(UI.Button({
		text = "Exit Program",
		x = centeredHorizontally,
		y = function()
			return app.root:getProp("height") - 1
		end,
	}):onClick(function()
		app:stop()
	end))
	:add(UI.Label({
		text = "'k' to increment, 'j' to decrement, 'q' to quit",
		x = centeredHorizontally,
		y = function()
			return app.root:getProp("height")
		end,
	}))

app:addEventListener("char", function(key)
	if key == "q" then
		app:stop()
	end
end)

app:addEventListener("key", function(key)
	local countEl = app.root:findById("count")
	if countEl == nil then
		return
	end
	---@cast countEl Label
	if key == keys.j then
		countEl:setState("count", countEl:getState("count") - 1)
	elseif key == keys.k then
		countEl:setState("count", countEl:getState("count") + 1)
	end
end)

app:start()
