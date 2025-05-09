local minify = loadfile("bin/minify.lua")()

local f = io.open("release/ui.lua", "r")
local content = f:read("*all")
f:close()

local success, minified = minify(content)
if not success then
  error(minified)
end

local f = io.open("release/ui.lua", "w")
f:write(minified)
f:close()
