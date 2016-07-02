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
  new = function(self, connection)
    local dao = {connection = connection}
    setmetatable(dao, {__index = self.metatable})
    return dao
  end,
}

M.metatable = {
  --[[
  Responsabilidade: Insere uma conferência no banco de dados
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber uma conferência com suas propriedades preenchidas
  Pós-Condição: * A conferência é inserida no Banco
                * Retorna erro se dados de conferência não existem
                * Caso ocorra um erro durante a inserção, retorna nil
  ]]
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


    --[[
    Responsabilidade: Busca todas as conferências
    Pré-Condição: * Banco de dados deve estar online
    Pós-Condição: * Todas as conferências contidas no banco de dados são retornadas
                  * Retorna uma lista vazia caso não existam conferências no banco
    ]]
  all = function(self)
    return Conference:build_all(self:__find_all({}))
  end,

  --[[
  Responsabilidade: Busca por uma determinada conferência por id
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber o id da conferência
  Pós-Condição: * A conferência que possui o id passado como parâmetro é terornada
                * Retorna nil caso não exista
  ]]
  find = function(self, id)
    local id = self:__safe_object_id(id)
    if not id then return nil end
    return Conference:new(self:__find_all({_id = id})[1])
  end,

  --[[
  Responsabilidade: Deleta uma determinada conferência por id
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber o id da conferência
  Pós-Condição: * A conferência que contém o id passado como parâmetro é deletada do banco de dados
                * Retorna nil caso não exista
  ]]
  delete = function(self, id)
    local id = self:__safe_object_id(id)
    if not id then return nil end
    return self:__collection():delete_one({_id = id}).acknowledged
  end,

  --[[
  Responsabilidade: Atualiza uma determinada conferência
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber a conferencia com os dados atualizados
  Pós-Condição: * Conferência é atualizada no banco de dados
                * Retorna nil caso ocorra algum problema na operação
  ]]
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


  --[[
  Responsabilidade: Função privada | busca por conferências usando query
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber a query de busca
  Pós-Condição: * Todas as conferências que retornam true para a query de busca são retornadas
  ]]
  __find_all = function(self, query)
    local query = query or {}
    return utils.map_iterator(self:__collection():find(query), function(conference_data)
      conference_data.id = conference_data._id.key
      conference_data._id = nil
      return conference_data
    end)
  end,

  --[[
  Responsabilidade: Função privada | obtem a collection de conferências do banco de dados (mongo)
  Pré-Condição: * Banco de dados deve estar online
  Pós-Condição: * Coleçao do mongo que trata de conferências é retornada
  ]]
  __collection = function(self)
    local database = self.connection:getDatabase("pes3")
    return database:getCollection("conferences")
  end,

  --[[
  Responsabilidade: Função privada | Verifica se o id da conferência está contido no banco de dados (mongo)
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber o id da conferência
  Pós-Condição: * Se conseguiu obter, retorna true
                * Se não conseguiu, retorna nil
  ]]
  __safe_object_id = function(self, id)
    local ok, ret_or_err = pcall(ObjectId.new, id)
    if ok then return ret_or_err else return nil end
  end,

  --[[
  Responsabilidade: Função privada | Converte a lista de editores de uma conferência é uma string contendo todos os autores (usado para busca)
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber a conferência contendo os editores
  Pós-Condição: * Retorna uma string contendo todos os editores concatenados por espaço
  ]]
  __extra_data_for = function(self, conference)
    return {editors_text = table.concat(conference.editors, " ")}
  end,
}

return M
