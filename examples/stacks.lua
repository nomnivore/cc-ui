require("_path")

local ui = require("ccui")

local ALIGNS = { "start", "center", "end", "stretch" }
local alignIdx = 1
local gap = 0
local added = 0
local clicks = { One = 0, Two = 0, Three = 0 }
local lastClick = "-"

-- left column: the stack with controls
local demo = ui.VStack({
	width = 20,
	height = "fill",
	bgColor = colors.gray,
	align = function()
		return ALIGNS[alignIdx]
	end,
	gap = function()
		return gap
	end,
	ui.Label({ text = "short", bgColor = colors.red }),
	ui.Label({ text = "a bit longer", bgColor = colors.green }),
	ui.Label({ text = "medium", bgColor = colors.blue }),
	ui.Label({ text = "fill", width = "fill", bgColor = colors.purple }),
	ui.ProgressBar({ width = "fill", value = 0.5, text = "half" }),
})

-- a frame that reports its own size
local function sizedFrame(color)
	return ui.Frame({
		height = "fill",
		bgColor = color,
		ui.Label({
			text = function(self)
				local w, h = self.parent:getSize()
				return w .. "x" .. h
			end,
		}),
	})
end

local function clickButton(name)
	return ui.Button({
		text = name,
		onClick = function()
			clicks[name] = clicks[name] + 1
			lastClick = name
		end,
	})
end

local app = ui.App({
	ui.VStack({
		width = "fill",
		height = "fill",
		ui.Label({ text = "stacks.lua   q quit", fgColor = colors.lightGray }),

		-- controls
		ui.HStack({
			gap = 1,
			ui.Button({
				text = function()
					return "align: " .. ALIGNS[alignIdx]
				end,
				onClick = function()
					alignIdx = alignIdx % #ALIGNS + 1
				end,
			}),
			ui.Button({
				text = function()
					return "gap: " .. gap
				end,
				onClick = function()
					gap = (gap + 1) % 3
				end,
			}),
			ui.Button({
				text = "add",
				onClick = function()
					added = added + 1
					demo:add(ui.Label({ text = "added " .. added, bgColor = colors.orange }))
				end,
			}),
		}),

		-- middle: takes all remaining rows
		ui.HStack({
			width = "fill",
			height = "fill",
			gap = 1,
			demo,
			ui.VStack({
				width = "fill",
				height = "fill",
				ui.Label({ text = "two fill frames" }),
				ui.Label({ text = "odd row -> first" }),
				sizedFrame(colors.red),
				sizedFrame(colors.blue),
			}),
		}),

		-- bottom: click targets
		ui.HStack({
			gap = 2,
			clickButton("One"),
			clickButton("Two"),
			clickButton("Three"),
		}),
		ui.Label({
			text = function()
				return ("One=%d  Two=%d  Three=%d  last: %s"):format(clicks.One, clicks.Two, clicks.Three, lastClick)
			end,
		}),
	}),
})

app:addEventListener("char", function(key)
	if key == "q" then
		app:stop()
	end
end)

app:start()
