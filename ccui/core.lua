local Frame = require("ccui.components.Frame")

---@class Core
---@field root Frame

local Core = {}
Core.__index = Core

local function clear()
  term.clear()
  term.setCursorPos(1, 1)
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
end

function Core.new()
  local self = setmetatable({}, Core)

  self.root = Frame.new({
    term = term.current(),
  })

  return self
end

function Core:start()
  clear()
  self.root:render()
  os.pullEvent("char")
  clear()
end

return Core