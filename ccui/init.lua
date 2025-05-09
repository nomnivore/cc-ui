local exports = {
  Core = require("ccui.core"),
  Components = require("ccui.components"),
  Util = require("ccui.util"),

  new = require("ccui.core").new,
}

return exports

-- To bundle, run:
-- bunx luabundler bundle .\ccui\init.lua -p "?.lua" -p "?\\init.lua" -o release/ccui.lua
-- (requires bun to be installed (or npm with npx))