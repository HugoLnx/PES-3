--[[conference DAO modulos
This modulo has the functions about the conference DAO's(Data acess Object)
]]
local Conference = require "models/conference"
local utils = require "utils"
local app = require "app"
local path = require "pl.path"
local file = require "pl.file"
local plutils = require "pl.utils"
local ObjectId = require("mongorover.luaBSONObjects").ObjectId

local M = {
  new = function(self, connection, app)
    local dao = {connection = connection}
    setmetatable(dao, {__index = self.metatable})
    return dao
  end,
}

M.metatable = {
  insert = function(self, conference)
    if not conference then error() end
    
    local result = self:__collection():insert_one(utils.merge(conference:data(), self:__extra_data_for(conference)))
    if result.acknowledged then
      local data = utils.merge(conference:data(), {id = result.inserted_id.key})
      local conference = Conference:new(data)
      return conference
    else
      return nil
    end
  end,

  all = function(self)
    return Conference:build_all(self:__find_all({}))
  end,

  find = function(self, id)
    local id = self:__safe_object_id(id)
    if not id then return nil end
    return Conference:new(self:__find_all({_id = id})[1])
  end,
  
  delete = function(self, id)
    local id = self:__safe_object_id(id)
    if not id then return nil end
    return self:__collection():delete_one({_id = id}).acknowledged
  end,
  
  update = function(self, conference)
    local data = utils.merge(conference:data(), self:__extra_data_for(conference))
    data.id = nil
    local id = self:__safe_object_id(conference.id)
    if not id then return nil end
    local result = self:__collection():update_one({_id = id}, {["$set"] = data})
    
    if result.raw_result.nMatched > 0 then
      local conference = self:find(conference.id)
      return conference
    else
      return nil
    end
  end,

  
  __find_all = function(self, query)
    local query = query or {}
    return utils.map_iterator(self:__collection():find(query), function(conference_data)
      conference_data.id = conference_data._id.key
      conference_data._id = nil
      return conference_data
    end)
  end,
  
  __collection = function(self)
    local database = self.connection:getDatabase("pes3")
    return database:getCollection("conferences")
  end,
  
  __safe_object_id = function(self, id)
    local ok, ret_or_err = pcall(ObjectId.new, id)
    if ok then return ret_or_err else return nil end
  end,
  
  __extra_data_for = function(self, conference)
    return {editors_text = table.concat(conference.editors, " ")}
  end,
}

return M
