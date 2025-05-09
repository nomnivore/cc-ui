local Util = {}

local id = 0
function Util.generateUniqueId()
	id = id + 1
	return id
end

---@alias Rect {x: number, y: number, width: number, height: number}

--- Checks if a point is inside a rectangle
---@param x number
---@param y number
---@param rect Rect
---@return boolean
function Util.pointInRect(x, y, rect)
	return x >= rect.x and x <= rect.x + rect.width - 1 and y >= rect.y and y <= rect.y + rect.height - 1
end

return Util
