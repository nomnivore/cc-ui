local Component = require("ccui.components.Component")

---@class LabelProps : ComponentProps
---@field text string|fun(self: Label): string

---@class Label : Component
---@field props LabelProps
local Label = {}
setmetatable(Label, Component)
Label.__index = Label

---@class NewLabelProps : NewComponentProps
---@field text string|nil|fun(self: Label): string

---@param props NewLabelProps
function Label.new(props)
  local self = Component.new(props)
  setmetatable(self, Label)
  ---@cast self Label

  self.props.type = "label"
  self.props.text = props.text or ""

  self.props.width = props.width or function(self) return #self:getProps("text") end
  return self
end

function Label:setText(text)
  self.props.text = text

  return self
end


---@param term ccTweaked.term.Redirect
function Label:render(term)
  local x = self:getProps("x")
  local y = self:getProps("y")
  local fg = self:getProps("fgColor", colors.white)
  local bg = self:getProps("bgColor", colors.black)
  local text = self:getProps("text")
  term.setCursorPos(x, y)
  term.blit(text, string.rep(colors.toBlit(fg), #text), string.rep(colors.toBlit(bg), #text))

  -- labels shouldn't have children anyway
  ---@todo remove
  Component.render(self, term)
end

return Label
