local exports = {
  Core = require("ccui.core"),
  Components = require("ccui.components"),
  Util = require("ccui.util"),

  new = require("ccui.core").new,
}

return exports

-- To bundle, run:
-- bunx luabundler bundle .\ccui\init.lua -p "?.lua" -p "?\\init.lua" -o release/ui.lua
-- (requires bun to be installed (or npm with npx))
-- Then, to minify, run:
-- lua bin/minify-release.lua