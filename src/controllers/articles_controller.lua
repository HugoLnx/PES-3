--[[
Módulo responsável por ser o controlador das rotas de artigo

Possui as seguintes funções:

index: lista de artigos
create: cria um artigos
update: atualiza um artigos
download: efetua o download de um pdf associado ao artigo
destroy: remove um artigo
show: exibe informações de um artigo específico
]]

local ArticleDao = require('models/article_dao')
local Article = require('models/article')
local ArticleSerializer = require('models/article_serializer')
local ConferenceDao = require('models/conference_dao')
local ConferenceSerializer = require('models/conference_serializer')
local Authentication = require('models/authentication')
local utils = require 'utils'
local view = require('view')

local M = {
  new = function(self, connection, app)
    local controller = {
      dao = ArticleDao:new(connection),
      conferenceDao = ConferenceDao:new(connection),
    }
    setmetatable(controller, {__index = self.metatable})
    return controller
  end,
}

M.metatable = {

  --[[
  Responsabilidade: Método para a rota principal da página de artigos
  Pré-Condição: * Deve receber parametros da rota
  Pós-Condição: * Retorna a página html renderizada contendo os artigos e se o usuário é admin ou não
  ]]
  index = function(self, params)
    local articles = self.dao:all(params.query)
    local conferences = self.conferenceDao:all()
    local auth = Authentication:new(params.cookie)

    return view.render("articles.html.elua", {args = {
      articles = ArticleSerializer:serialize_many(articles),
      conferences = ConferenceSerializer:serialize_many(conferences),
      query = params.query,
      is_admin = auth:is_signedin(),
    }})
  end,

  --[[
  Responsabilidade: Método para a rota de criação de artigo
  Pré-Condição: * Deve receber parametros da rota (dados de artigo)
  Pós-Condição: * Cria artigo
                * Retorna a página html contendo os artigos, incluindo o novo
  ]]
  create = function(self, params)
    params.authors = utils.split(params.authors, "[^,]+")

    local article = Article:new(params)
    article = self.dao:insert(article, params.document)

    return view.redirect_to("/articles.html")
  end,

  --[[
  Responsabilidade: Método para a rota de download de documento associado ao artigo
  Pré-Condição: * Deve receber parametros da rota (id do artigo)
  Pós-Condição: * Obtem o caminho do arquivo
                * Retorna resposta contendo o arquivo associado ao artigo
  ]]
  download = function(self, params)
    local article, file = self.dao:download(params.id)

    if article then
      return view.respond_with({
        status = 200,
        body = file,
        headers = {
          ["Content-Type"] = "application/octet-stream",
          ["Content-Disposition"] = "attachment;filename='"..article.title..".pdf'",
        },
      })
    else
      return view.respond_with({
        status = 404,
        body = '{"error" : "Not found"}',
        headers = {
          ["Content-Type"] = "application/json",
        },
      })
    end
  end,

  --[[
  Responsabilidade: Método para a rota de atualização de artigo
  Pré-Condição: * Deve receber parametros da rota (dados de artigo a serem atualiados)
  Pós-Condição: * Atualiza artigo
                * Retorna a página html contendo os artigos, incluindo artigo com os dados atualizados
  ]]
  update = function(self, params)
    local article = self.dao:update(Article:new(params), params.document)
    if article then
      return view.redirect_to("/articles.html")
    else
      return view.render("not_found.html.elua", {status = 404})
    end
  end,

  --[[
  Responsabilidade: Método para a rota de remoção de artigo
  Pré-Condição: * Deve receber parametros da rota (id do artigo)
  Pós-Condição: * Remove artigo
                * Retorna a página html contendo as artigos
  ]]
  destroy = function(self, params)
    if self.dao:delete(params.id) then
      return view.redirect_to("/articles.html")
    else
      return view.render("not_found.html.elua", {status = 404})
    end
  end,

  --[[
  Responsabilidade: Método para a rota de exibição uma de artigo específico
  Pré-Condição: * Deve receber parametros da rota (id da artigo)
  Pós-Condição: * Retorna a página html contendo as informações do artigo especificado
  ]]
  show = function(self, params)
    local article = self.dao:find(params.id)
    local auth = Authentication:new(params.cookie)

    if article then
      return view.render("article.html.elua", {args = {
        article = ArticleSerializer:serialize_one(article),
        is_admin = auth:is_signedin(),
      }})
    else
      return view.render("not_found.html.elua", {status = 404})
    end
  end,
}

return M
