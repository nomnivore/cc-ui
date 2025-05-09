local Component = require("ccui.components.Component")

---@class ButtonProps : ComponentProps
---@field text string|fun(self: Button): string

---@class Button : Component
---@field props ButtonProps
local Button = {}
setmetatable(Button, Component)
Button.__index = Button

---@class NewButtonProps : NewComponentProps
---@field text string|nil|fun(self: Button): string

---@param props NewButtonProps
function Button.new(props)
	local self = Component.new(props)
	setmetatable(self, Button)
	---@cast self Button

	self.props.type = "button"
	self.props.text = props.text or ""
	self.props.width = props.width or function(self)
		return #self:getProps("text") + 2
	end
	self.props.height = props.height or 1

	return self
end

---@param term ccTweaked.term.Redirect
function Button:render(term)
	local bg = self:getProps("bgColor", colors.white)
	local fg = self:getProps("fgColor", colors.black)
	local x = self:getProps("x")
	local y = self:getProps("y")
	local width = self:getProps("width")
	local height = self:getProps("height")
	local text = self:getProps("text")

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

	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)

	Component.render(self, term)
end

return Button
