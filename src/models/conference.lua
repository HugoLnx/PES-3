--[[conference Modulo
This modulo is responsible to play the role of model in MVC design pattern.
]]
local utils = require "utils"
local path = require "pl.path"

local ATTRIBUTES = {"id", "abbreviation", "name", "location", "month", "year", "editors", "creation_date"}

local function to_data(values)
  local data = {}
  for _,attribute in ipairs(ATTRIBUTES) do
    data[attribute] = values[attribute]
  end
  return data
end

local M = {
  new = function(self, values)
    local conference = to_data(values)
    conference.creation_date = conference.creation_date or os.date()
    setmetatable(conference, {__index = self.metatable})
    return conference
  end,
  
  build_all = function(self, conferences_data)
    local conferences = {}
    for i,values in ipairs(conferences_data) do
      conferences[#conferences+1] = self:new(values)
    end
    return conferences
  end,
  
  data_of_all = function(self, conferences)
    return utils.map(conferences, function(conference) return conference:data() end)
  end,
}

M.metatable = {
  data = function(self)
    return to_data(self)
  end
}

return M
