local Component = require("ccui.components.Component")
local util = require("ccui.util")

---@class CheckboxProps : ComponentProps
---@field checked boolean|nil|fun(self: Checkbox): boolean

---@class Checkbox : Component
---@overload fun(props: NewCheckboxProps?): Checkbox
---@field props CheckboxProps
local Checkbox = util.class(Component)

---@class NewCheckboxProps : NewComponentProps
---@field checked boolean|nil|fun(self: Checkbox): boolean

---@param props NewCheckboxProps?
function Checkbox.new(props)
	props = props or {}
	local self = Component.new(props, Checkbox)
	---@cast self Checkbox

	self.props.type = "checkbox"
	self.props.checked = props.checked or false

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
		self:setProp("checked", not self:getProp("checked"))
	else
		self:setProp("checked", value)
	end

	return self
end

--- Gets the checked state
---@return boolean
function Checkbox:isChecked()
	return self:getProp("checked")
end

---Returns the size the component would like to take, based on its content
---@return integer width, integer height
function Checkbox:getPreferredSize()
	return 3, 1
end

---@param term ccTweaked.term.Redirect
function Checkbox:render(term)
	local x = self.rect.x
	local y = self.rect.y
	local bgColor = self:getProp("bgColor")
	local fgColor = self:getProp("fgColor")
	local checked = self:getProp("checked")
	term.setCursorPos(x, y)
	term.blit(checked and "[x]" or "[ ]", string.rep(colors.toBlit(fgColor), 3), string.rep(colors.toBlit(bgColor), 3))
end

return Checkbox
