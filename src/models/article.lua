--[[article Modulo
This modulo is responsible to play the role of model in MVC design pattern.
]]

local utils = require "utils"
local path = require "pl.path"

local ATTRIBUTES = {"id", "title", "abstract", "authors", "downloads", "quoting_rate", "document_text", "creation_date", "conference_id"}

--[[
Responsabilidade: Retorna dados do artigo baseado numa lista de atributos
Pré-Condição: * Deve receber os dados de artigo
Pós-Condição: * Retorna dados do artigo baseado numa lista de atributos
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
    local article = to_data(values)
    article.downloads = article.downloads or 0
    article.quoting_rate = article.quoting_rate or 0
    article.creation_date = article.creation_date or os.date()
    setmetatable(article, {__index = self.metatable})
    return article
  end,

  --[[
  Responsabilidade: Retorna artigos a partir de uma lista de dados de artigo
  Pré-Condição: * Deve receber objetos contendo dados de artigo
  Pós-Condição: * Retorna todos os artigos criados a partir dos dados
  ]]
  build_all = function(self, articles_data)
    local articles = {}
    for i,values in ipairs(articles_data) do
      articles[#articles+1] = self:new(values)
    end
    return articles
  end,

  --[[
  Responsabilidade: Retorna lista de dados de artigos a partir de uma lista de artigos
  Pré-Condição: * Deve receber uma lista de artigos
  Pós-Condição: * Retorna todos os dados de artigos convertidos a partir dos artigos
  ]]
  data_of_all = function(self, articles)
    return utils.map(articles, function(article) return article:data() end)
  end,
}

M.metatable = {
  --[[
  Responsabilidade: Retorna somente os dados de artigo
  Pré-Condição: * -
  Pós-Condição: * Retorna somente os dados de artigo
  ]]
  data = function(self)
    return to_data(self)
  end,

  --[[
  Responsabilidade: Retorna caminho do arquivo associado ao artigo
  Pré-Condição: * Deve existir um id válido
  Pós-Condição: * Retorna caminho do arquivo associado ao artigo
  ]]
  document_path = function(self)
    return path.join("articles", self.id .. ".pdf")
  end,
}

return M
