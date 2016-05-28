local cjson = require "cjson"
local utils = require "utils"
local multipart = require "multipart"

local DEFAULT_HEADERS = { ["Content-Type"] = "application/json" }

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
    ngx.say(output.body)
    ngx.exit(output.status or ngx.HTTP_OK)
  end,
  
  __get_args = function(self)
    local args = {}
    local add_arg = function(key, value)
      local parts = utils.split(key, "[^.]+")
      if #parts == 1 then
        args[key] = value
      else
        local attr = parts[1]
        local inx = parts[2]
        if inx:match("^%d+$") then inx = tonumber(inx) end
        args[attr] = args[attr] or {}
        args[attr][inx] = value
      end
    end
    self.ngx.req.read_body()
    for k,v in pairs(self.ngx.req.get_uri_args()) do
      add_arg(k, v)
    end
    local multipart_data = multipart(ngx.req.get_body_data(), ngx.req.get_headers()["Content-Type"])
    for k,v in pairs(multipart_data:get_all()) do
      add_arg(k, v)
    end
    return args
  end
}

return M
