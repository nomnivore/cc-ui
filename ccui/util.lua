local Util = {}

local id = 0
function Util.generateUniqueId()
	id = id + 1
	return id
end

---@alias TextValue string|number
---@alias Rect {x: number, y: number, width: number, height: number}

--- Checks if a point is inside a rectangle
---@param x number
---@param y number
---@param rect Rect
---@return boolean
function Util.pointInRect(x, y, rect)
	return x >= rect.x and x <= rect.x + rect.width - 1 and y >= rect.y and y <= rect.y + rect.height - 1
end

local function callNew(cls, ...)
	return cls.new(...)
end

---@param parent any? parent class, expecting a table but typed 'any' due to LuaLS @overload issues
---@return table
function Util.class(parent)
	local cls = {}
	cls.__index = cls
	cls.__call = callNew

	if parent then
		setmetatable(cls, parent)
	else
		setmetatable(cls, { __call = callNew })
	end

	return cls
end

return Util
