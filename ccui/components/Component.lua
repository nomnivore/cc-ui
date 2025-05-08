---@class Component
---@field type string
---@field x number
---@field y number
---@field width number
---@field height number
---@field bgColor ccTweaked.colors.color?
---@field fgColor ccTweaked.colors.color?
---@field parent Component?
---@field children Component[]
local Component = {}
Component.__index = Component

---@class ComponentProps
---@field type string?
---@field x number?
---@field y number?
---@field width number?
---@field height number?
---@field bgColor ccTweaked.colors.color?
---@field fgColor ccTweaked.colors.color?

---@param props ComponentProps
function Component.new(props)
  local self = setmetatable({}, Component)

  -- props with default values
  self.type = "component"
  self.x = 1
  self.y = 1
  self.width = 1
  self.height = 1

  -- props defined in table arg
  for k, v in pairs(props) do
    self[k] = v
  end

  self.parent = nil
  self.children = {}

  return self
end

---@param child Component
function Component:add(child)
  child.parent = self
  table.insert(self.children, child)

  return self
end

---Recursively scans the component tree for a component at the given position
---Preference is given to children over the parent
---@param x number
---@param y number
---@return Component?
function Component:findComponentAt(x, y)
  for _, child in ipairs(self.children) do
    local result = child:findComponentAt(x, y)
    if result then
      return result
    end
  end

  if self.x and self.y then
    if x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height then
      return self
    end
  end

  return nil

end

---@param term ccTweaked.term.Redirect
function Component:render(term)
  if self.x and self.y then
    term.setCursorPos(self.x, self.y)
  end

  for _, child in ipairs(self.children) do
    if self.bgColor then
      term.setBackgroundColor(self.bgColor)
    end
    if self.fgColor then
      term.setTextColor(self.fgColor)
    end
    child:render(term)
  end
end

return Component