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

---@param text string
function Label:setText(text)
	self:setProps("text", text)

	return self
end

---@return string
function Label:getText()
	return tostring(self:getProps("text"))
end

---@param term ccTweaked.term.Redirect
function Label:render(term)
	local x = self:getProps("x")
	local y = self:getProps("y")
	local fg = self:getProps("fgColor", colors.white)
	local bg = self:getProps("bgColor", colors.black)
	local text = self:getText()
	term.setCursorPos(x, y)
	term.blit(text, string.rep(colors.toBlit(fg), #text), string.rep(colors.toBlit(bg), #text))

	-- labels shouldn't have children anyway
	---@todo remove
	Component.render(self, term)
end

return Label
