local M = {
  new = function(self, cookie)
    local obj = {cookie = cookie}
    setmetatable(obj, {__index = self.metatable})
    return obj
  end,
}

M.metatable = {
  login = function(self, password)
    if password == "pes3pes3" then
      self.cookie:set({
          key = "type",
          value = "user",
      })
      return true
    else
      return false
    end
  end,
  
  logout = function(self)
    self.cookie:set({
        key = "type",
        value = "anonymous",
    })
  end,
  
  is_signedin = function(self)
    return self.cookie:get("type") == "user"
  end,
}

return M
