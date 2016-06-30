local view = require('view')
local Authentication = require('models/authentication')

local M = {
  new = function(self)
    local controller = {}
    setmetatable(controller, {__index = self.metatable})
    return controller
  end,
}

M.metatable = {
  login = function(self, params)
    return view.render("login.html.elua")
  end,
  
  authenticate = function(self, params)
    local auth = Authentication:new(params.cookie)
    if auth:login(params.password) then
      return view.redirect_to("/")
    else
      return view.render("login.html.elua", {args = {err = "Senha incorreta"}})
    end
  end,
  
  logout = function(self, params)
    local auth = Authentication:new(params.cookie)
    auth:logout()
    return view.redirect_to("/")
  end,

  info = function(self, params)
    local auth = Authentication:new(params.cookie)
    return view.render_json{logged = auth:is_signedin()}
  end
}

return M
