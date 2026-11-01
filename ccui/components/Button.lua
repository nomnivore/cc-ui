local Component = require("ccui.components.Component")

---@class ButtonProps : ComponentProps
---@field text TextValue|fun(self: Button): TextValue

---@class Button : Component
---@field props ButtonProps
local Button = {}
setmetatable(Button, Component)
Button.__index = Button

---@class NewButtonProps : NewComponentProps
---@field text TextValue|nil|fun(self: Button): TextValue

---@param props NewButtonProps?
function Button.new(props)
	props = props or {}
	local self = Component.new(props)
	setmetatable(self, Button)
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
	self:setProps("text", text)

	return self
end

---@return string
function Button:getText()
	return tostring(self:getProps("text"))
end

---@param term ccTweaked.term.Redirect
function Button:render(term)
	local bg = self:getProps("bgColor")
	local fg = self:getProps("fgColor")
	local x = self:getProps("x")
	local y = self:getProps("y")
	local width = self:getProps("width")
	local height = self:getProps("height")
	local text = self:getText()

	local labelY = y + math.floor((height - 1) / 2)

	term.setBackgroundColor(bg)
	term.setTextColor(fg)

	term.setCursorPos(x, y)
	-- print entire width/height using bg color
	for i = 1, height do
		term.setCursorPos(x, y + i - 1)
		term.write(string.rep(" ", width))
	end

	term.setCursorPos(x + 1, labelY)
	term.write(text)

	Component.render(self, term)
end

return Button
