--[[conference serializer modulos
This modulo has the functions about the conference serializer
]]
local utils = require "utils"

local function data_for(conference)
  return utils.merge(conference:data(), {
    editors = table.concat(conference.editors, ", "),
    view_path = "/conferences/" .. conference.id .. ".html",
  })
end

return {
  serialize_one = function(self, conference)
    return data_for(conference)
  end,
  
  serialize_many = function(self, conferences)
    return utils.map(conferences, function(conference) return data_for(conference) end)
  end,
}

