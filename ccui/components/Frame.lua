local Component = require("ccui.components.Component")
local util = require("ccui.util")

---@class FrameProps : ComponentProps
---@field term ccTweaked.term.Redirect

---@class Frame : Component
---@overload fun(props?: NewFrameProps): Frame
---@field props FrameProps
local Frame = util.class(Component)

---@class NewFrameProps : NewComponentProps
---@field term ccTweaked.term.Redirect?

---@param frame Frame
local function defaultSize(frame)
	-- use 'term' prop if present, otherwise use parent size
	---@type ccTweaked.term.Redirect?
	local t = frame:getProp("term")

	if t then
		return t.getSize()
	end

	if not frame.parent then
		return 0, 0
	end

	return frame.parent:getProp("width", 0), frame.parent:getProp("height", 0)
end

--- Creates a new frame component, which is a container for other components.
--- Also acts as a root component for an app.
--- Size defaults to the remaining space in the parent window/terminal if no width/height are given
---@param props NewFrameProps?
function Frame.new(props)
	props = props or {}
	local self = Component.new(props)
	setmetatable(self, Frame --[[@as table]])
	---@cast self Frame

	self.props.type = "frame"

	self.props.x = props.x or 1
	self.props.y = props.y or 1
	self.props.width = props.width
		or function(s)
			---@cast s Frame
			local w = defaultSize(s)
			return w - s:getProp("x") + 1
		end
	self.props.height = props.height
		or function(s)
			---@cast s Frame
			local _, h = defaultSize(s)
			return h - s:getProp("y") + 1
		end

	return self
end

--- Adds a child component to this component, mounting it if this component is mounted
---@param child Component
function Frame:add(child)
	child.parent = self
	table.insert(self.children, child)

	if self.app then
		child:mount(self.app)
	end

	return self
end

--- Finds the target component at the given coordinates
---@param x integer
---@param y integer
---@return Component?
function Frame:findTarget(x, y)
	if not self:hitTest(x, y) then
		-- outside bounds
		return
	end

	-- recursively check if the coord belongs to a child component
	-- searching last-to-first
	for i = #self.children, 1, -1 do
		local hit = self.children[i]:findTarget(x, y)
		if hit then
			return hit
		end
	end

	return self
end

---@param term ccTweaked.term.Redirect
function Frame:render(term)
	local x = self:getProp("x")
	local y = self:getProp("y")
	local bgColor = self:getProp("bgColor")
	local fgColor = self:getProp("fgColor")
	local width = self:getProp("width")
	local height = self:getProp("height")

	-- window scopes the frame & its children to its defined space
	local win = window.create(term, x, y, width, height)
	win.setBackgroundColor(bgColor)
	win.setTextColor(fgColor)

	-- fills background color
	win.clear()

	-- render children
	for _, child in ipairs(self.children) do
		-- sane defaults
		win.setCursorPos(1, 1)
		win.setBackgroundColor(bgColor)
		win.setTextColor(fgColor)

		child:render(win)
	end
end

return Frame
