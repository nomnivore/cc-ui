require("_path")

-- Simple counter example app using ccui

local ui = require("ccui")

local function centeredHorizontally(self)
	return math.floor((self.parent:getProp("width") - self:getProp("width")) / 2)
end

local app = ui.App({
	ui.Label({
		text = "Counter",
		x = centeredHorizontally,
		y = 1,
	}),
	ui.Label({
		text = function(self)
			return self:getState("count")
		end,
		x = centeredHorizontally,
		y = 2,
		id = "count",
		state = {
			count = 0,
		},
	}),
	ui.Button({
		text = "Increment",
		x = function(self)
			return centeredHorizontally(self) - 6
		end,
		y = 3,
		bgColor = colors.green,
		fgColor = colors.white,
	}):onClick(function(self)
		local el = self.app.root:findById("count")
		if not el then
			return
		end
		el:setState("count", el:getState("count") + 1)
	end),
	ui.Button({
		text = "Decrement",
		x = function(self)
			return centeredHorizontally(self) + 6
		end,
		y = 3,
		bgColor = colors.red,
		fgColor = colors.white,
	}):onClick(function(self)
		local el = self.app.root:findById("count")
		if not el then
			return
		end
		el:setState("count", el:getState("count") - 1)
	end),
	ui.Button({
		text = "Exit Program",
		x = centeredHorizontally,
		y = function(self)
			return self.app.root:getProp("height") - 1
		end,
	}):onClick(function(self)
		self.app:stop()
	end),
	ui.Label({
		text = "'k' to increment, 'j' to decrement, 'q' to quit",
		x = centeredHorizontally,
		y = function(self)
			return self.app.root:getProp("height")
		end,
	}),
})

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
