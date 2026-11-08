local Component = require("ccui.components.Component")
local util = require("ccui.util")

---@class FrameProps : ComponentProps

---@class Frame : Component
---@overload fun(props?: NewFrameProps): Frame
---@field props FrameProps
local Frame = util.class(Component)
Frame.isContainer = true

---@class NewFrameProps : NewComponentProps
---@field [integer] Component|false

---Returns a window at the given rect inside `parent`, reusing the cached one when possible
---@param holder Component
---@param parent ccTweaked.Window
---@param key "window"|"contentWindow"
---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@return ccTweaked.Window
local function placeWindow(holder, key, parent, x, y, w, h)
	local entry = holder[key]
	if entry == nil or entry.parent ~= parent then
		entry = { parent = parent, win = window.create(parent, x, y, w, h) }
		holder[key] = entry
	else
		-- if position or size differ, reposition
		local wX, wY = entry.win.getPosition()
		local wW, wH = entry.win.getSize()

		if wX ~= x or wY ~= y or wW ~= w or wH ~= h then
			entry.win.reposition(x, y, w, h)
		end
	end
	return entry.win
end

--- Creates a new frame component, which is a container for other components.
--- Also acts as a root component for an app.
--- Size defaults to the remaining space in the parent window/terminal if no width/height are given
---@param props NewFrameProps?
---@return Frame
function Frame.new(props)
	props = props or {}
	local self = Component.new(props, Frame)
	---@cast self Frame

	self.props.type = "frame"

	self.props.width = props.width or "fill"
	self.props.height = props.height or "fill"

	-- add children from positional arguments
	for _, v in ipairs(props) do
		if type(v) == "table" and v.mount then
			self:add(v)
		end
	end

	return self
end

--- Adds a child component to this component, mounting it if this component is mounted
---@param child Component
---@generic T: Frame
---@param self T
---@return T
function Frame:add(child)
	---@cast self Frame
	child.parent = self
	table.insert(self.children, child)

	if self.app then
		child:mount(self.app)
	end

	return self
end

--- Finds the target component at the given coordinates
---@param x integer
---@param y integer
---@return Component?
function Frame:findTarget(x, y)
	if not self:hitTest(x, y) then
		-- outside bounds
		return
	end

	-- recursively check if the coord belongs to a child component
	-- searching last-to-first
	for i = #self.children, 1, -1 do
		local hit = self.children[i]:findTarget(x, y)
		if hit then
			return hit
		end
	end

	return self
end

---Computes the rect of each child, then lays out the child
function Frame:layout()
	local cw, ch = self:getSize() -- content size of this container

	for _, child in ipairs(self.children) do
		local w, h = child:measure(cw, ch)
		child.rect = { x = 1, y = 1, width = w, height = h } -- provisional
		local x, y = child:getProp("x", 1), child:getProp("y", 1)
		if child:getProp("width") == "fill" then
			w = cw - x + 1
		end
		if child:getProp("height") == "fill" then
			h = ch - y + 1
		end
		child.rect = { x = x, y = y, width = w, height = h }
		child:layout()
	end
end

---@param win ccTweaked.Window
function Frame:render(win)
	-- render children
	for _, child in ipairs(self.children) do
		if child.rect.width > 0 and child.rect.height > 0 then
			local childWin =
				placeWindow(child, "window", win, child.rect.x, child.rect.y, child.rect.width, child.rect.height)
			child:draw(childWin)
		end
	end
end

return Frame
