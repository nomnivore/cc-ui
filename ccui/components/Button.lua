local Component = require("ccui.components.Component")
local util = require("ccui.util")

---@class ButtonProps : ComponentProps
---@field text TextValue|fun(self: Button): TextValue

---@class Button : Component
---@overload fun(props?: NewButtonProps): Button
---@field props ButtonProps
local Button = util.class(Component)

---@class NewButtonProps : NewComponentProps
---@field text TextValue|nil|fun(self: Button): TextValue

---@param props NewButtonProps?
function Button.new(props)
	props = props or {}
	local self = Component.new(props, Button)
	---@cast self Button

	self.props.type = "button"
	self.props.text = props.text or ""
	self.props.width = props.width or function(self)
		return #self:getText() + 2
	end
	self.props.height = props.height or 1
	self.props.bgColor = props.bgColor or colors.white
	self.props.fgColor = props.fgColor or colors.black

	return self
end

---@param text TextValue|fun(self: Button): TextValue
function Button:setText(text)
	self:setProp("text", text)

	return self
end

---@return string
function Button:getText()
	return tostring(self:getProp("text"))
end

---Returns the size the component would like to take, based on its content
---@return integer width, integer height
function Button:getPreferredSize()
	local text = self:getText()
	return #text + 2, 1
end

---@param term ccTweaked.term.Redirect
function Button:render(term)
	local _, height = self:getSize()
	local text = self:getText()

	local labelY = 1 + math.floor((height - 1) / 2)

	term.setCursorPos(2, labelY)
	term.write(text)
end

return Button
