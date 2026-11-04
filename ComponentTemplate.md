- add to `ccui/components` folder
- export it from `ccui/components/init.lua`, and again in `ccui/init.lua`

```lua
local Component = require("ccui.components.Component")
local util = require("ccui.util")

---@class CXProps : ComponentProps

---@class CX : Component
---@overload fun(props?: NewCXProps): CX
---@field props CXProps
local CX = util.class(Component)

---@class NewCXProps : NewComponentProps

---@param props NewCXProps?
function CX.new(props)
	props = props or {}
	local self = Component.new(props, CX)
	---@cast self CX

	self.props.type = "cx"

	-- set default props

	return self
end

---@param term ccTweaked.term.Redirect
function CX:render(term)
	--TODO:
end

return CX
```
