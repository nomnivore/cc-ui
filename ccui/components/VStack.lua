local Stack = require("ccui.components.Stack")
local util = require("ccui.util")

---@class VStackProps : StackProps

---Vertical Stack wrapper
---@class VStack : Stack
---@overload fun(props?: NewVStackProps): VStack
---@field props VStackProps
local VStack = util.class(Stack)

---@class NewVStackProps : NewStackProps
---@field direction "vertical"|nil

---@param props NewVStackProps?
function VStack.new(props)
	props = props or {}
	-- forced direction
	props.direction = "vertical"
	local self = Stack.new(props, VStack)
	---@cast self VStack

	self.props.type = "vstack"

	-- set default props

	return self
end

return VStack

