--[[
Módulo responsável por fornecer funções de renderização de html e json
]]


local template = require "resty.template"
local utils = require "utils"
local path = require "pl.path"
local cjson = require "cjson"

local RENDER_DEFAULT_PARAMS = {
  status = 200,
  headers = {["Content-Type"] = "text/html"},
}

local RENDER_DEFAULT_JSON_PARAMS = {
  status = 200,
  headers = {["Content-Type"] = "application/json"},
}

M = {}

M.respond_with = function(params)
  return params
end

--[[
Responsabilidade: Renderizar uma página html
Pré-Condição: * Deve receber parametros
Pós-Condição: * Retorna a página html renderizada
]]
M.render = function(view_path, params)
  local params = params or {}
  local view = template.new(path.join("views", view_path), path.join("views", "layout.html.elua"))
  utils.copy_to(params.args or {}, view)
  params.args = nil
  return M.respond_with(utils.merge(RENDER_DEFAULT_PARAMS, params, {body = tostring(view)}))
end
--[[
Responsabilidade: Converte objeto lua (tabela) para json
Pré-Condição: * Deve receber objeto lua como parâmetro
Pós-Condição: * Retorna json contendo os dados do objeto lua
]]
M.render_json = function(table, params)
  local params = params or {}
  return M.respond_with(utils.merge(RENDER_DEFAULT_JSON_PARAMS, params, {body = cjson.encode(table)}))
end

--[[
Responsabilidade: Redireciona para outra página
Pré-Condição: * -
Pós-Condição: * Redireciona para outra página
]]
M.redirect_to = function(path, params)
  return M.respond_with({redirect_to = path})
end

return M
