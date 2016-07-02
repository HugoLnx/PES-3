local M = {
  new = function(self, cookie)
    local obj = {cookie = cookie}
    setmetatable(obj, {__index = self.metatable})
    return obj
  end,
}

M.metatable = {
  --[[
  Responsabilidade: Verifica se um usuário é capaz de efetuar login
  Pré-Condição: * Deve receber a senha de acesso
  Pós-Condição: * Caso possa efetuar login, cookie de acesso é criado
                * Retorna true ou false se pode ou não efetuar login
  ]]
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

  --[[
  Responsabilidade: Faz logout do usuário
  Pré-Condição: * -
  Pós-Condição: * invalida o cookie de login
  ]]
  logout = function(self)
    self.cookie:set({
        key = "type",
        value = "anonymous",
    })
  end,

  --[[
  Responsabilidade: Verifica se o usuário está logado através do cookie
  Pré-Condição: * -
  Pós-Condição: * Retorna true ou false se o usuário está logado ou não
  ]]
  is_signedin = function(self)
    return self.cookie:get("type") == "user"
  end,
}

return M
