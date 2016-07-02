--[[
Módulo responsável por ser o controlador das rotas autenticação de usuário

Possui as seguintes funções:

login: exibe página de login
authenticate: verifica se a senha de usuário é válida
logout: efetua o logout do usuário
]]

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

  --[[
  Responsabilidade: Método para a rota de login
  Pré-Condição: * -
  Pós-Condição: * Retorna a página de login
  ]]
  login = function(self, params)
    return view.render("login.html.elua")
  end,

  --[[
  Responsabilidade: Método para a rota de autenticação
  Pré-Condição: * Deve receber parametros da rota (senha, cookie, etc)
  Pós-Condição: * Retorna a página raiz ou retorna página de senha incorreta caso a senha esteja incorreta
  ]]
  authenticate = function(self, params)
    local auth = Authentication:new(params.cookie)
    if auth:login(params.password) then
      return view.redirect_to("/")
    else
      return view.render("login.html.elua", {args = {err = "Senha incorreta"}})
    end
  end,


  --[[
  Responsabilidade: Método para a rota de logout
  Pré-Condição: * Deve receber parametros da rota (cookie)
  Pós-Condição: * Retorna a página raiz
  ]]
  logout = function(self, params)
    local auth = Authentication:new(params.cookie)
    auth:logout()
    return view.redirect_to("/")
  end,

  --[[
  Responsabilidade: Método para a rota de informação do usuário
  Pré-Condição: * Deve receber parametros da rota (cookie)
  Pós-Condição: * Retorna um json informando se o usuário está logado ou não
  ]]
  info = function(self, params)
    local auth = Authentication:new(params.cookie)
    return view.render_json{logged = auth:is_signedin()}
  end
}

return M
