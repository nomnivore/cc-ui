local Util = {}

local id = 0
function Util.generateUniqueId()
  id = id + 1
  return id
end

return Util