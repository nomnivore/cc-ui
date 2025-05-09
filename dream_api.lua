-- this file represents how i want the api to function when its done
-- it will NOT work right now

local UI = require("ccui")

-- returns a Frame (root component) for the provided terminal
-- monitor peripherals could be supported
local app = UI.new({
  term = term, -- default: term
})

app:add(UI.Label({
  text = "Hello World!",
  x = 1,
  y = 1,
  width = 10,
  height = 1,
  backgroundColor = colors.black,
  textColor = colors.white,
  
}))

app:start()