local Component = require("ccui.components.Component")

---@class Frame
---@field term term
---@field x number
---@field y number
---@field width number
---@field height number
---@field bgColor ccTweaked.colors.color?
---@field fgColor ccTweaked.colors.color?
---@field type string
---@field parent Component?
---@field children Component[]

-- Container component. Also acts as a root component for an app.
local Frame = {}
setmetatable(Frame, Component)
Frame.__index = Frame

---@class FrameProps
---@field term term?
---@field x number?
---@field y number?
---@field width number?
---@field height number?
---@param props FrameProps
function Frame.new(props)
  local self = Component.new(props)
  setmetatable(self, Frame)

  local tW, tH = term.getSize()

  self.type = "frame"

  self.x = props.x or 1
  self.y = props.y or 1
  self.width = props.width or tW
  self.height = props.height or tH

  return self
end

function Frame:render()
  term.setCursorPos(self.x, self.y)
  if self.bgColor then
    term.setBackgroundColor(self.bgColor)
  end
  if self.fgColor then
    term.setTextColor(self.fgColor)
  end

  -- print entire width/height using bg color
  for i = 1, self.height do
    term.write(string.rep(" ", self.width))
  end

  -- reset cursor position
  term.setCursorPos(self.x, self.y)

  -- render children
  Component.render(self)
end

return Frame