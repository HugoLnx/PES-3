--[[conference Modulo
This modulo is responsible to play the role of model in MVC design pattern.
]]
local utils = require "utils"
local path = require "pl.path"

local ATTRIBUTES = {"id", "abbreviation", "name", "location", "month", "year", "editors", "creation_date"}


--[[
Responsabilidade: Retorna dados da conferência baseado numa lista de atributos
Pré-Condição: * Deve receber os dados de conferência
Pós-Condição: * Retorna dados de conferência baseado numa lista de atributos
]]
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


    --[[
    Responsabilidade: Retorna conferências a partir de uma lista de dados de conferência
    Pré-Condição: * Deve receber objetos contendo dados de conferência
    Pós-Condição: * Retorna todas as conferências criadas a partir dos dados
    ]]
  build_all = function(self, conferences_data)
    local conferences = {}
    for i,values in ipairs(conferences_data) do
      conferences[#conferences+1] = self:new(values)
    end
    return conferences
  end,

  --[[
  Responsabilidade: Retorna lista de dados de conferências a partir de uma lista de conferências
  Pré-Condição: * Deve receber uma lista de conferências
  Pós-Condição: * Retorna todos os dados de conferências convertidos a partir das conferências
  ]]
  data_of_all = function(self, conferences)
    return utils.map(conferences, function(conference) return conference:data() end)
  end,
}

M.metatable = {
  --[[
  Responsabilidade: Retorna somente os dados de conferência
  Pré-Condição: * -
  Pós-Condição: * Retorna somente os dados de conferência
  ]]
  data = function(self)
    return to_data(self)
  end
}

return M
