local Frame = require("ccui.components.Frame")
local util = require("ccui.util")

---@alias StackAlign "start"|"center"|"end"|"stretch"
---@alias StackDirection "vertical"|"horizontal"

---@class StackProps : FrameProps
---@field gap integer|fun(self: Stack): integer
---@field align StackAlign|fun(self: Stack): StackAlign
---@field direction StackDirection|fun(self: Stack): StackDirection

---Child 'x' and 'y' props are ignored
---Main-axis 'fill' prop in children is 0 if the stack fits-to-content on that axis (Default)
---@class Stack : Frame
---@overload fun(props?: NewStackProps): Stack
---@field props StackProps
local Stack = util.class(Frame)

---@class NewStackProps : NewFrameProps
---@field gap integer|nil|fun(self: Stack): integer
---@field align StackAlign|nil|fun(self: Stack): StackAlign
---@field direction StackDirection|nil|fun(self: Stack): StackDirection

---@param props NewStackProps?
---@param cls any? class to instantiate, default Frame
function Stack.new(props, cls)
	props = props or {}
	cls = cls or Stack
	local self = Frame.new(props, cls)
	---@cast self Stack

	self.props.type = "stack"

	-- set default props
	self.props.gap = props.gap or 0
	self.props.align = props.align or "start"
	self.props.direction = props.direction or "vertical"
	-- stacks fit their content by default (overriding Frame default to "fill")
	self.props.width = props.width
	self.props.height = props.height

	return self
end

---@param horizontal boolean
---@param w integer
---@param h integer
---@return integer, integer
local function toAxes(horizontal, w, h)
	if horizontal then
		return w, h
	end
	return h, w
end

---Returns the size the component would like to take, based on its content
---@return integer width, integer height
function Stack:getPreferredSize()
	local horiz = self:getProp("direction") == "horizontal"
	local gap = self:getProp("gap")
	local l, t, r, b = self:getInsets()
	local mainInset, crossInset = toAxes(horiz, l + r, t + b)

	local mainSizeSum = math.max(0, gap * (#self.children - 1))
	local crossSize = 0

	for _, child in ipairs(self.children) do
		local chMain, chCross = toAxes(horiz, child:measure(0, 0))
		mainSizeSum = mainSizeSum + chMain
		crossSize = math.max(crossSize, chCross)
	end

	return mainSizeSum + mainInset, crossSize + crossInset
end

---Computes the rect of each child, then lays out the child
function Stack:layout()
	local horiz = self:getProp("direction") == "horizontal"
	local gap = self:getProp("gap")
	local align = self:getProp("align")
	local cRect = self:getContentRect()
	local mainSize, crossSize = toAxes(horiz, cRect.width, cRect.height)
	local mainProp = horiz and "width" or "height"

	local sizes = {}
	local used, fillCount = 0, 0
	-- measure all child components
	for idx, child in ipairs(self.children) do
		local chMain, chCross = toAxes(horiz, child:measure(cRect.width, cRect.height))
		if child:getProp(mainProp) == "fill" then
			table.insert(sizes, idx, { fill = true, cross = chCross })
			fillCount = fillCount + 1
		else
			table.insert(sizes, idx, { main = chMain, cross = chCross })
			used = used + chMain
		end
	end
	used = used + math.max(0, gap * (#self.children - 1))
	local leftover = math.max(0, mainSize - used)

	-- place child rects
	local pos = 1
	local share, extra = 0, 0
	if fillCount > 0 then
		share = math.floor(leftover / fillCount)
		extra = leftover % fillCount
	end
	for idx, child in ipairs(self.children) do
		local s = sizes[idx]

		-- main size
		local chMain = s.main
		if s.fill then
			chMain = share
			if extra > 0 then
				chMain = chMain + 1
				extra = extra - 1
			end
		end

		-- cross size
		local chCross = s.cross
		if align == "stretch" then
			chCross = crossSize
		end

		-- cross pos
		local crossPos = 1 -- 'start'
		if align == "center" then
			crossPos = math.floor((crossSize - chCross) / 2) + 1
		elseif align == "end" then
			crossPos = crossSize - chCross + 1
		end

		-- convert back to x/y/w/h
		local w, h = toAxes(horiz, chMain, chCross)
		local x, y = toAxes(horiz, pos, crossPos)
		child.rect = { x = x, y = y, width = w, height = h }
		child:layout()

		pos = pos + chMain + gap
	end
end

return Stack
