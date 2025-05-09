local Component = require("ccui.components.Component")
local Frame = require("ccui.components.Frame")
local Util = require("ccui.util")

---@alias EventFn fun(self: Component, ...)

---@class Core
---@field root Frame
---@field term ccTweaked.term.Redirect
---@field running boolean
---@field private events table<ccTweaked.os.event, EventFn[]>
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
  self.events = {}
  
  local test = self.events["alarm"]

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

---Adds an event listener to the core, which will now be checked for in the main event loop.
---Returns the core and the callback function, which can be used to remove the listener.
---@param event string
---@param callback EventFn
---@return Core, EventFn
function Core:addEventListener(event, callback)
  if not self.events[event] then
    self.events[event] = {}
  end
  table.insert(self.events[event], callback)

  return self, callback
end

---Removes an event listener from the core
---@param event string
---@param callback EventFn
---@return Core
function Core:removeEventListener(event, callback)
  if not self.events[event] then
    return self
  end

  for i, v in ipairs(self.events[event]) do
    if v == callback then
      table.remove(self.events[event], i)
      break
    end
  end

  return self
end

---Mounts the root component and starts the main event loop
---@return Core
function Core:start()
  -- first render
  self.root:mount(self)
  self:renderUI()

  self.running = true
  while self.running do
    self:renderUI()
    local event, param1, param2, param3 = os.pullEvent()
    if self.events[event] then
      for _, callback in ipairs(self.events[event]) do
        callback(param1, param2, param3)
      end
    end

    -- if event == "char" then
    --   if param1 == "q" then
    --     self:stop()
    --   end
    -- end
  end
  self:clearScreen()

  return self
end

---Stops the main event loop and unmounts the root component
---@return Core
function Core:stop()
  self.running = false

  return self
end

return Core