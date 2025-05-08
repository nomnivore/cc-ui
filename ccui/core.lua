local Frame = require("ccui.components.Frame")

---@class Core
---@field root Frame
---@field term ccTweaked.term.Redirect
---@field running boolean
local Core = {}
Core.__index = Core

-- used to hang onto the global term object
local ccterm = term


---@return Core
---@param term ccTweaked.term.Redirect?
function Core.new(term)
  local self = setmetatable({}, Core)

  self.term = term or ccterm.current()
  self.root = Frame.new({
    term = self.term,
  })
  self.running = false

  return self
end

function Core:clearScreen()
  self.term.clear()
  self.term.setCursorPos(1, 1)
  self.term.setTextColor(colors.white)
  self.term.setBackgroundColor(colors.black)
end

function Core:renderUI()
  self:clearScreen()
  self.root:render(self.term)
end

function Core:start()
  -- first render
  self:renderUI()

  self.running = true
  while self.running do
    self:renderUI()
    local event, param1, param2, param3 = os.pullEvent()

    if event == "mouse_click" then
      local component = self.root:findComponentAt(param2, param3)
      if component and component.onClick then
        ---@todo WARNING: this does not work for non-clickables nested inside clickables!
        component:onClick()
      end
    elseif event == "char" then
      if param1 == "q" then
        self:stop()
      end
    end
  end
  self:clearScreen()
end

function Core:stop()
  self.running = false
end

return Core