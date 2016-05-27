local cjson = require "cjson"
local utils = require "utils"

local DEFAULT_HEADERS = { ["Content-Type"] = "application/json" }

local function tojson(json)
  if json.collection ~= nil and #json.collection == 0 then
    json.collection = ":_:collection:_:"
  end
  local json_str, _ = cjson.encode(json):gsub('":_:collection:_:"', "[]")
  return json_str
end

local M = {
  new = function(self, ngx, connection)
    local controller = {connection = connection, ngx = ngx}
    setmetatable(controller, {__index = self.metatable})
    return controller
  end,
}

M.metatable = {
  call = function(self, calling)
    local ngx = self.ngx
    local controller = require(calling.controller .. "_controller"):new(self.connection)
    local action = calling.action
    local args = self:__get_args() 
    
    local output = controller[action](controller, args) 
    local headers = utils.merge(DEFAULT_HEADERS, (output.headers or {}))
    
    for header,value in pairs(headers) do
      ngx.header[header] = value
    end
    ngx.say(tojson(output.json))
    ngx.exit(output.status or ngx.HTTP_OK)
  end,
  
  __get_args = function(self)
    local args = {}
    self.ngx.req.read_body()
    for k,v in pairs(self.ngx.req.get_uri_args()) do
      args[k] = v
    end
    for k,v in pairs(self.ngx.req.get_post_args()) do
      args[k] = v
    end
    return args
  end
}

return M
