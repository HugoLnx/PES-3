--[[article DAO modulos
This modulo has the functions about the article DAO's(Data acess Object)
]]
local Article = require "models/article"
local DocumentParser = require "models/document_parser"
local utils = require "utils"
local app = require "app"
local path = require "pl.path"
local file = require "pl.file"
local plutils = require "pl.utils"
local ConferenceDAO = require("models/conference_dao")
local ObjectId = require("mongorover.luaBSONObjects").ObjectId

local M = {
  new = function(self, connection)
    local dao = {
      connection = connection,
      conferenceDao = ConferenceDAO:new(connection),
    }
    setmetatable(dao, {__index = self.metatable})
    return dao
  end,
}

M.metatable = {

  --[[
  Responsabilidade: Insere um artigo no banco de dados, e salva seu documento associado
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber um artigo com suas propriedades preenchidas
                * Deve receber o caminho do arquivo vinculado aos dados do artigo
  Pós-Condição: * O artigo é inserido no Banco
                * O documento relacionado ao artigo é movido da pasta temporária para a pasta de documentos de artigos
  ]]
  insert = function(self, article, uploaded_document)
    if not article or not uploaded_document then error() end

    article.document_text = DocumentParser:get_text(uploaded_document.path)
    local result = self:__collection():insert_one(utils.merge(article:data(), self:__extra_data_for(article)))
    if result.acknowledged then
      local data = utils.merge(article:data(), {id = result.inserted_id.key})
      local article = Article:new(data)
      self:__move_uploaded_document(uploaded_document, article)
      return article
    else
      return nil
    end
  end,

  --[[
  Responsabilidade: Busca todos os artigos por termo de busca
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber o termo de busca (string)
  Pós-Condição: * Retorna todos os artigos que contêm em seu conteúdo o termo de busca
                * Se o termo de busca estiver vazio, retorna todos os artigos
  ]]
  all = function(self, search_term)
    if search_term and search_term ~= "" then
      return self:__all{["$text"] = {["$search"] = search_term}}
    else
      return self:__all()
    end
  end,

  --[[
  Responsabilidade: Busca todos os artigos de uma conferência
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber o id da conferência
  Pós-Condição: * Retorna todos os artigos da conferência com o id passado como parâmetro
  ]]
  all_on_conference = function(self, conference_id)
    return self:__all{conference_id = conference_id}
  end,

  --[[
  Responsabilidade: Busca artigo por id
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber o id do artigo a ser procurado
  Pós-Condição: * Retorna o artigo que tenha como id o id passado como parâmetro
                * Retorna nil se o id é inválido
  ]]
  find = function(self, id)
    local id = self:__safe_object_id(id)
    if not id then return nil end
    return self:__build_article(self:__find_all({_id = id})[1])
  end,

  --[[
  Responsabilidade: Deleta um determinado artigo do banco
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber o id do artigo a ser deletado
  Pós-Condição: * Retorna o artigo que tenha como id o id passado como parâmetro
                * Retorna nil se o id é inválido
  ]]
  delete = function(self, id)
    local id = self:__safe_object_id(id)
    if not id then return nil end
    return self:__collection():delete_one({_id = id}).acknowledged
  end,

  --[[
  Responsabilidade: Atualiza um determinado artigo no banco de dados
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber o artigo a ser atualizado
                * Deve receber o caminho do documento que deva ser atualizado
  Pós-Condição: * Artigo é atualizado
                * Documento associado ao artigo é atualizado
                * Retorna nil caso não encontre o artigo a ser atualizado
  ]]
  update = function(self, article, uploaded_document)
    local data = utils.merge(article:data(), self:__extra_data_for(article))
    data.id = nil
    local id = self:__safe_object_id(article.id)
    if not id then return nil end
    local result = self:__collection():update_one({_id = id}, {["$set"] = data})

    if result.raw_result.nMatched > 0 then
      local article = self:find(article.id)
      self:__move_uploaded_document(uploaded_document, article)
      return article
    else
      return nil
    end
  end,

  --[[
  Responsabilidade: Incrementa contador de downloads do artigo e retorna caminho do mesmo
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber o id do artigo a ser atualizado
  Pós-Condição: * Contador de downloads para o artido é incrementado
                * Retorna o caminho do arquivo do artigo
                * retorna o artigo com o contador de downloads atualizado
  ]]
  download = function(self, id)
    local objId = self:__safe_object_id(id)
    if not objId then return nil end
    self:__collection():update_one({_id = objId}, {["$inc"] = {downloads = 1}})
    local article = self:find(id)
    local file = plutils.readfile(self:__document_abs_path(article), true)
    return article, file
  end,

  --[[
  Responsabilidade: Função privada | retorna todos os artigos baseado em uma query
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber a query de busca
  Pós-Condição: * Returna todos os artigos encontrados pela query
  ]]
  __all = function(self, query)
    local query = query or {}
    local articles = Article:build_all(self:__find_all(query))
    for i,article in ipairs(articles) do
      articles[i] = self:__build_article(article:data())
    end
    return articles
  end,

  --[[
  Responsabilidade: Função privada | retorna todos os dados de artigo baseado em uma query
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber a query de busca
  Pós-Condição: * Returna todos os dados de artigos encontrados pela query
  ]]
  __find_all = function(self, query)
    local query = query or {}
    return utils.map_iterator(self:__collection():find(query), function(article_data)
      article_data.id = article_data._id.key
      article_data._id = nil
      return article_data
    end)
  end,

  --[[
  Responsabilidade: Função privada | Move o arquvivo do artigo do diretório temporário para o diretŕio de artigos
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber artigo
                * Deve receber o caminho temporário do documento
  Pós-Condição: * Documento é movido para o diretório de artigos
  ]]
  __move_uploaded_document = function(self, uploaded_document, article)
    if not uploaded_document then return end
    local destination_path = self:__document_abs_path(article)
    file.delete(destination_path)
    file.move(uploaded_document.path, destination_path)
  end,

  --[[
  Responsabilidade: Função privada | Retorna o caminho absoluto do arquivo associado ao artigo
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber artigo
  Pós-Condição: * Caminho absoluto para o arquivo associado é montado e retornado pela função
  ]]
  __document_abs_path = function(self, article)
    return path.join(app.root, "documents", article.id .. ".pdf")
  end,

  --[[
  Responsabilidade: Função privada | Obtem a coleção do banco (mongo) de artigos
  Pré-Condição: * Banco de dados deve estar online
  Pós-Condição: * Coleção do mongo que armazena os artigos é retornada
  ]]
  __collection = function(self)
    local database = self.connection:getDatabase("pes3")
    return database:getCollection("articles")
  end,

  --[[
  Responsabilidade: Função privada | Verifica se o id do artigo está contido no banco de dados (mongo)
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber o id do artigo
  Pós-Condição: * Se conseguiu obter, retorna true
                * Se não conseguiu, retorna nil
  ]]
  __safe_object_id = function(self, id)
    local ok, ret_or_err = pcall(ObjectId.new, id)
    if ok then return ret_or_err else return nil end
  end,

  --[[
  Responsabilidade: Função privada | Converte a lista de autores de um artigo é uma string contendo todos os autores (usado para busca)
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber o artigo contendo os autores
  Pós-Condição: * Retorna uma string contendo todos os autores concatenados por espaço
  ]]
  __extra_data_for = function(self, article)
    return {authors_text = table.concat(article.authors, " ")}
  end,

  --[[
  Responsabilidade: Função privada | Constroi um artigo a partir dos seus dados e associa com a conferência
  Pré-Condição: * Banco de dados deve estar online
                * Deve receber os dados do artigo
  Pós-Condição: * Controi o objeto artigo e associa a conferência
  ]]
  __build_article = function(self, data)
    local article = Article:new(data)
    if article.conference_id then
      article.conference = self.conferenceDao:find(article.conference_id)
    end
    return article

  end
}

return M
