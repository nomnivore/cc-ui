local Component = require("ccui.components.Component")

---@class Button
---@field x number
---@field y number
---@field width number
---@field height number
---@field bgColor ccTweaked.colors.color?
---@field fgColor ccTweaked.colors.color?
---@field type string
---@field parent Component?
---@field children Component[]
---@field text string
---@field onClick fun(self: Button)

local Button = {}
setmetatable(Button, Component)
Button.__index = Button

---@class ButtonProps
---@field type string?
---@field x number
---@field y number
---@field width number?
---@field height number?
---@field bgColor ccTweaked.colors.color?
---@field fgColor ccTweaked.colors.color?
---@field text string?
---@field onClick fun(self: Button)

---@param props ButtonProps
function Button.new(props)
  local self = Component.new(props)
  setmetatable(self, Button)
  self.type = "button"
  self.text = props.text or ""
  self.onClick = props.onClick or function() end
  self.width = props.width or #self.text + 2
  self.height = props.height or 1
  return self
end

---@param term ccTweaked.term.Redirect
function Button:render(term)
  local bg = self.fgColor or colors.white
  local fg = self.bgColor or colors.black
  -- term.blit(self.text, string.rep(colors.toBlit(fg), #self.text), string.rep(colors.toBlit(bg), #self.text))

  local labelY = self.y + math.floor((self.height - 1) / 2)

  term.setBackgroundColor(bg)
  term.setTextColor(fg)

  term.setCursorPos(self.x, self.y)
  -- print entire width/height using bg color
  for i = 1, self.height do
    term.write(string.rep(" ", self.width))
  end

  term.setCursorPos(self.x + 1, labelY)
  term.write(self.text)

  Component.render(self, term)
end

return Button
