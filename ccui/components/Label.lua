local Component = require("ccui.components.Component")

---@class Label : Component
---@field text string
local Label = {}
setmetatable(Label, Component)
Label.__index = Label

---@class LabelProps : ComponentProps
---@field text string?

---@param props LabelProps
function Label.new(props)
  local self = Component.new(props)
  setmetatable(self, Label)
  ---@cast self Label

  self.type = "label"
  self.text = props.text or ""
  return self
end

function Label:setText(text)
  self.text = text

  return self
end


---@param term ccTweaked.term.Redirect
function Label:render(term)
  term.setCursorPos(self.x, self.y)
  local fg = self.fgColor or colors.white
  local bg = self.bgColor or colors.black
  term.blit(self.text, string.rep(colors.toBlit(fg), #self.text), string.rep(colors.toBlit(bg), #self.text))

  -- labels shouldn't have children anyway
  ---@todo remove
  Component.render(self, term)
end

return Label
