--[[conference serializer modulos
This modulo has the functions about the conference serializer
]]
local utils = require "utils"


--[[
Responsabilidade: Monta um objeto com dados de conferÇencia e demais dados para serem usados no html
Pré-Condição: * Banco de dados deve estar online
              * Deve receber uma conferência com suas propriedades preenchidas
Pós-Condição: * Editores são convertidos em uma string onde são separados por vírgula
              * Caminho do html é formado usando o id da conferência
              * Retorna o objeto
]]
local function data_for(conference)
  local articles = conference.articles or {}
  local articles_count = table.getn(articles)
  local downloads_count = 0
  for _,article in ipairs(articles) do
    downloads_count = downloads_count + (article.downloads or 0)
  end
  return utils.merge(conference:data(), {
    editors = table.concat(conference.editors, ", "),
    view_path = "/conferences/" .. conference.id .. ".html",
    articles_count = articles_count,
    downloads = downloads_count,
  })
end

return {
  serialize_one = function(self, conference)
    return data_for(conference)
  end,

  serialize_many = function(self, conferences)
    return utils.map(conferences, function(conference) return data_for(conference) end)
  end,
}
