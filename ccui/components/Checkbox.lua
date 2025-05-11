local Component = require("ccui.components.Component")

---@class CheckboxProps : ComponentProps
---@field checked boolean|nil|fun(self: Checkbox): boolean

---@class Checkbox : Component
---@field props CheckboxProps
local Checkbox = {}
setmetatable(Checkbox, Component)
Checkbox.__index = Checkbox

---@class NewCheckboxProps : NewComponentProps
---@field checked boolean|nil|fun(self: Checkbox): boolean

---@param props NewCheckboxProps
function Checkbox.new(props)
	local self = Component.new(props)
	setmetatable(self, Checkbox)
	---@cast self Checkbox

	self.props.type = "checkbox"
	self.props.checked = props.checked or false
	self.props.height = 1
	self.props.width = 3

	self:onClick(function()
		self:toggle()
	end)

	return self
end

--- Toggles the checkbox, or sets it to the given value
--- If 'props.checked' is a function, it will only be overridden if 'value' is not nil
---@param value boolean|nil
function Checkbox:toggle(value)
	if value == nil then
		if type(self.props.checked) == "function" then
			return
		end
		self:setProps("checked", not self:getProps("checked"))
	else
		self:setProps("checked", value)
	end

	return self
end

--- Gets the checked state
---@return boolean
function Checkbox:isChecked()
	return self:getProps("checked")
end

---@param term ccTweaked.term.Redirect
function Checkbox:render(term)
	local x = self:getProps("x")
	local y = self:getProps("y")
	local bgColor = self:getProps("bgColor", colors.black)
	local fgColor = self:getProps("fgColor", colors.white)
	local checked = self:getProps("checked")
	term.setCursorPos(x, y)
	term.blit(checked and "[x]" or "[ ]", string.rep(colors.toBlit(fgColor), 3), string.rep(colors.toBlit(bgColor), 3))

	-- checkboxes shouldn't have children anyway
	---@todo remove
	Component.render(self, term)
end

return Checkbox
