--[[
Módulo responsável por ser o controlador das rotas documentos

Possui as seguintes funções:
read: lê o conteúdo de um pdf e retorna as informações em json

]]

local DocumentParser = require('models/document_parser')
local view = require('view')

local M = {
  new = function(self, connection, app)
    local controller = {}
    setmetatable(controller, {__index = self.metatable})
    return controller
  end,
}

M.metatable = {
  --[[
  Responsabilidade: Método para a rota que recebe o pdf e retorna o texto contido nele
  Pré-Condição: * Deve receber parametros da rota (contendo o caminho do pdf)
  Pós-Condição: * Retorna um json contendo o texto do pdf
  ]]
  read = function(self, params)
    local text = DocumentParser:get_text(params.document.path)

    return view.render_json{raw = text}
  end
}

return M
