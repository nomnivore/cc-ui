local Component = require("ccui.components.Component")

---@class FrameProps : ComponentProps
---@field term ccTweaked.term.Redirect

---@class Frame : Component
---@field props FrameProps
local Frame = {}
setmetatable(Frame, Component)
Frame.__index = Frame

---@class NewFrameProps : NewComponentProps
---@field term ccTweaked.term.Redirect?

--- Creates a new frame component, which is a container for other components.
--- Also acts as a root component for an app.
--- Defaults to the size of the terminal if no width/height are specified.
---@param props NewFrameProps?
function Frame.new(props)
	props = props or {}
	local self = Component.new(props)
	setmetatable(self, Frame)
	---@cast self Frame

	local scopedTerm = props.term or term

	local tW, tH = scopedTerm.getSize()

	self.props.type = "frame"

	self.props.x = props.x or 1
	self.props.y = props.y or 1
	self.props.width = props.width or tW
	self.props.height = props.height or tH

	return self
end

---@param term ccTweaked.term.Redirect
function Frame:render(term)
	local x = self:getProps("x")
	local y = self:getProps("y")
	local bgColor = self:getProps("bgColor")
	local fgColor = self:getProps("fgColor")
	local width = self:getProps("width")
	local height = self:getProps("height")

	-- window scopes the frame & its children to its defined space
	local win = window.create(term, x, y, width, height)
	win.setBackgroundColor(bgColor)
	win.setTextColor(fgColor)

	-- fills background color
	win.clear()

	-- render children
	Component.render(self, win)
end

return Frame
