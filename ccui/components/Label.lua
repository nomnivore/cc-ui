local Component = require("ccui.components.Component")

---@class LabelProps : ComponentProps
---@field text TextValue|fun(self: Label): TextValue

---@class Label : Component
---@field props LabelProps
local Label = {}
setmetatable(Label, Component)
Label.__index = Label

---@class NewLabelProps : NewComponentProps
---@field text TextValue|nil|fun(self: Label): TextValue

---@param props NewLabelProps?
function Label.new(props)
	props = props or {}
	local self = Component.new(props)
	setmetatable(self, Label)
	---@cast self Label

	self.props.type = "label"
	self.props.text = props.text or ""

	self.props.width = props.width or function(self)
		return #self:getText()
	end
	return self
end

---@param text TextValue|fun(self: Label): TextValue
function Label:setText(text)
	self:setProp("text", text)

	return self
end

---@return string
function Label:getText()
	return tostring(self:getProp("text"))
end

---@param term ccTweaked.term.Redirect
function Label:render(term)
	local x = self:getProp("x")
	local y = self:getProp("y")
	local fg = self:getProp("fgColor")
	local bg = self:getProp("bgColor")
	local text = self:getText()
	term.setCursorPos(x, y)
	term.blit(text, string.rep(colors.toBlit(fg), #text), string.rep(colors.toBlit(bg), #text))
end

return Label
