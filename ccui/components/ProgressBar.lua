local Component = require("ccui.components.Component")
local util = require("ccui.util")

---@class ProgressBarProps : ComponentProps
---@field value number|fun(self: ProgressBar): number current progress
---@field max number|fun(self: ProgressBar): number max progress
---@field fillColor ccTweaked.colors.color|fun(self: ProgressBar): ccTweaked.colors.color color of the filled portion
---@field text string|nil|fun(self: ProgressBar): string|nil

---@class ProgressBar : Component
---@overload fun(props?: NewProgressBarProps): ProgressBar
---@field props ProgressBarProps
local ProgressBar = util.class(Component)

---@class NewProgressBarProps : NewComponentProps
---@field value number|nil|fun(self: ProgressBar): number current progress
---@field max number|nil|fun(self: ProgressBar): number max progress
---@field fillColor ccTweaked.colors.color|nil|fun(self: ProgressBar): ccTweaked.colors.color color of the filled portion
---@field text string|nil|fun(self: ProgressBar): string|nil

---@param props NewProgressBarProps?
function ProgressBar.new(props)
	props = props or {}
	local self = Component.new(props, ProgressBar)
	---@cast self ProgressBar

	self.props.type = "progressbar"

	-- set default props
	self.props.value = props.value or 0
	self.props.max = props.max or 1
	self.props.fillColor = props.fillColor or colors.lime

	return self
end

---Sensible default
---@return integer, integer
function ProgressBar:getPreferredSize()
	return 10, 1
end

---@param term ccTweaked.term.Redirect
function ProgressBar:render(term)
	local value = tonumber(self:getProp("value", 0)) or 0 -- safety for anything parsed NaN
	local max = self:getProp("max")
	value = math.max(0, math.min(value, max))
	local width = self:getSize()
	local filled = 0
	if max > 0 then
		filled = math.floor(value / max * width + 0.5)
	end
	local empty = width - filled
	local text = tostring(self:getProp("text", ""))
	local fg = self:getProp("fgColor")
	local bg = self:getProp("bgColor")
	local fillColor = self:getProp("fillColor")

	if #text > width then
		text = string.sub(text, 1, width)
	elseif #text < width then
		local left = math.floor((width - #text) / 2)
		text = string.rep(" ", left) .. text .. string.rep(" ", width - #text - left)
	end

	local fgBlit = string.rep(colors.toBlit(fg), width)
	local bgBlit = string.rep(colors.toBlit(fillColor), filled) .. string.rep(colors.toBlit(bg), empty)

	term.blit(text, fgBlit, bgBlit)
end

return ProgressBar
