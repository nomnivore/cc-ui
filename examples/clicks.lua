require("_path")

-- Throwaway test for tree dispatch (step 4). Each target has a counter below.
--   1. overlap: click where A and B overlap   -> only B (added last, on top)
--   2. clipped: click the visible half        -> button
--               click right of the gray frame -> nothing at all
--               click empty gray space         -> frame
--   3. bubble:  click "button"                 -> button only
--               click the label                -> frame (target: label)
--               click empty blue space         -> frame (target: frame)
--   4. late:    press 'l', then click "late"   -> late (onClick added after start)
--   5. off:     click "off me", press 'o'      -> stops counting

local UI = require("ccui")
local c = UI.Components

local app = UI.new()

local counts = { A = 0, B = 0, clipBtn = 0, clipFrame = 0, bubBtn = 0, bubFrame = 0, late = 0, off = 0 }
local bubbleTarget = "-"
local lateAttached, offRemoved = false, false

local function counter(key)
	return function()
		counts[key] = counts[key] + 1
	end
end

app.root:add(c.Label.new({ text = "clicks.lua   q quit   l late   o off" }))

-- 1. overlap: A spans x 2..11, B spans x 7..16
app.root:add(c.Label.new({ x = 2, y = 3, text = "1 overlap", fgColor = colors.lightGray }))
app.root:add(c.Button.new({ x = 2, y = 4, text = "AAAAAAAA", bgColor = colors.red }):onClick(counter("A")))
app.root:add(c.Button.new({ x = 7, y = 4, text = "BBBBBBBB", bgColor = colors.lime }):onClick(counter("B")))

-- 2. clipped: the button overflows the right edge of the gray frame
app.root:add(c.Label.new({ x = 20, y = 3, text = "2 clipped", fgColor = colors.lightGray }))
app.root:add(c.Frame
	.new({ x = 20, y = 4, width = 12, height = 3, bgColor = colors.gray })
	:add(c.Button.new({ x = 7, y = 2, text = "clipped!" }):onClick(counter("clipBtn")))
	:onClick(counter("clipFrame")))

-- 3. bubble: clickable frame containing a button and a handler-less label
app.root:add(c.Label.new({ x = 2, y = 7, text = "3 bubble", fgColor = colors.lightGray }))
app.root:add(c.Frame
	.new({ x = 2, y = 8, width = 30, height = 5, bgColor = colors.lightBlue })
	:add(c.Button.new({ x = 2, y = 2, text = "button" }):onClick(counter("bubBtn")))
	:add(c.Label.new({ x = 2, y = 4, text = "label (no handler)", fgColor = colors.black }))
	:onClick(function(_, e)
		counts.bubFrame = counts.bubFrame + 1
		bubbleTarget = e.target:getProps("type")
	end))

-- 4. late: gets an onClick only after 'l' is pressed
app.root:add(c.Label.new({ x = 35, y = 7, text = "4 late / 5 off", fgColor = colors.lightGray }))
local lateLabel = c.Label.new({ x = 35, y = 8, text = "late", bgColor = colors.orange })
app.root:add(lateLabel)

-- 5. off: handler removed with the same function reference
local offHandler = counter("off")
local offButton = c.Button.new({ x = 35, y = 10, text = "off me" }):onClick(offHandler)
app.root:add(offButton)

-- results
local function row(y, fn)
	app.root:add(c.Label.new({ x = 2, y = y, text = fn }))
end
row(14, function()
	return ("1  A=%d  B=%d"):format(counts.A, counts.B)
end)
row(15, function()
	return ("2  button=%d  frame=%d"):format(counts.clipBtn, counts.clipFrame)
end)
row(16, function()
	return ("3  button=%d  frame=%d  (last frame target: %s)"):format(counts.bubBtn, counts.bubFrame, bubbleTarget)
end)
row(17, function()
	return ("4  late=%d  %s"):format(counts.late, lateAttached and "(attached)" or "(press l)")
end)
row(18, function()
	return ("5  off=%d  %s"):format(counts.off, offRemoved and "(removed)" or "(press o)")
end)

app:addEventListener("char", function(key)
	if key == "q" then
		app:stop()
	elseif key == "l" and not lateAttached then
		lateLabel:onClick(counter("late"))
		lateAttached = true
	elseif key == "o" and not offRemoved then
		offButton:off("click", offHandler)
		offRemoved = true
	end
end)

app:start()
