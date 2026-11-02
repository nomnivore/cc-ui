require("_path")

local UI = require("ccui")
local c = UI.Components

-- render to a monitor on top if one is attached, otherwise the computer's own screen
local target = nil
if peripheral.getType("top") == "monitor" then
	local monitor = peripheral.wrap("top") --[[@as ccTweaked.peripherals.Monitor]]
	monitor.setTextScale(0.5)
	target = monitor
end

local app = UI.new(target)

local value = 0
app.root:setProps("bgColor", colors.green)

app.root:add(c.Frame
	.new({
		x = 5,
		y = 5,
		width = 20,
		height = 6,
		bgColor = colors.lightBlue,
	})
	:add(c.Label.new({
		text = function(self)
			local x, y = self:getScreenPos()
			return "x: " .. x .. ", y: " .. y
		end,
	}))
	:add(c.Button.new({
		x = 2,
		y = 4,
		text = function()
			return "click: " .. tostring(value)
		end,
		onClick = function(self)
			value = value + 1
		end,
	}))
	:add(c.Label.new({
		y = 6,
		text = "this is a really long bit of text that should be longer than 20 characters and thus get cut off",
	})))

-- Default-size test: a nested Frame with no width/height.
-- Outer frame is 20x10 at (28, 3); the inner frame sits at (4, 3) inside it.
--   "fill remaining" -> inner is 17x8, and the '<' / 'v' corner markers are visible
--   "fill parent"    -> inner is 20x10, and both markers are clipped off (invisible)
app.root:add(c.Frame
	.new({
		x = 28,
		y = 3,
		width = 20,
		height = 10,
		bgColor = colors.gray,
	})
	:add(c
		.Frame
		.new({
			x = 4,
			y = 3,
			bgColor = colors.orange,
		})
		-- two levels of nesting: expect screen (31, 5)
		:add(c.Label.new({
			text = function(self)
				local x, y = self:getScreenPos()
				return x .. "," .. y
			end,
		}))
		-- the size the inner frame believes it has
		:add(c.Label.new({
			y = 2,
			text = function(self)
				local w, h = self.parent:getSize()
				return w .. "x" .. h
			end,
		}))
		-- right-edge marker: drawn in the frame's last column
		:add(c.Label.new({
			text = "<",
			x = function(self)
				return self.parent:getProps("width")
			end,
			y = 4,
		}))
		-- bottom-edge marker: drawn in the frame's last row
		:add(c.Label.new({
			text = "v",
			x = 2,
			y = function(self)
				return self.parent:getProps("height")
			end,
		}))))


app:addEventListener("char", function(key)
	if key == "q" then
		app:stop()
	end
end)

app:start()
