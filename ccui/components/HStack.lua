local Stack = require("ccui.components.Stack")
local util = require("ccui.util")

---@class HStackProps : StackProps

---Horizontal Stack wrapper
---@class HStack : Stack
---@overload fun(props?: NewHStackProps): VStack
---@field props HStackProps
local HStack = util.class(Stack)

---@class NewHStackProps : NewStackProps
---@field direction "horizontal"|nil

---@param props NewHStackProps?
function HStack.new(props)
	props = props or {}
	-- forced direction
	props.direction = "horizontal"
	local self = Stack.new(props, HStack)
	---@cast self HStack

	self.props.type = "hstack"

	-- set default props

	return self
end

return HStack
