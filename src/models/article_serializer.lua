--[[article serializer modulos
This modulo has the functions about the article serializer
]]
local utils = require "utils"
local ConferenceSerializer = require "models/conference_serializer"

--[[
Responsabilidade: Monta um objeto com dados de artigo e demais dados para serem usados no html
Pré-Condição: * Banco de dados deve estar online
              * Deve receber um artigo com suas propriedades preenchidas
Pós-Condição: * Caminho do download é fornecido
              * Autores são convertidos em uma string onde são separados por vírgula
              * caminho do html é formado usando o id do artigo
              * Conferencia é adicionada ao objeto
              * Retorna o objeto
]]
local function data_for(article)
  local data = utils.merge(article:data(), {
    download_path = article:document_path(),
    authors = table.concat(article.authors, ", "),
    view_path = "/articles/" .. article.id .. ".html",
  })
  if article.conference then
    data.conference = ConferenceSerializer:serialize_one(article.conference)
  else
    data.conference = {}
  end
  return data
end

return {
  serialize_one = function(self, article)
    return data_for(article)
  end,

  serialize_many = function(self, articles)
    return utils.map(articles, function(article) return data_for(article) end)
  end,
}
