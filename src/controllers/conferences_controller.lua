--[[  conferences_controller Módulo
modulo responsible for being the conference controller

it has the functions:
index: Indexa a conferência
create: Cria uma conferência
update: Atualiza uma conferência
destroy: Deleta uma conferência
show: Mostra uma conferência

]]

local ConferenceDao = require('models/conference_dao')
local Conference = require('models/conference')
local ConferenceSerializer = require('models/conference_serializer')
local ArticleDao = require('models/article_dao')
local ArticleSerializer = require('models/article_serializer')
local Authentication = require('models/authentication')
local utils = require 'utils'
local view = require 'view'

local M = {
  new = function(self, connection, app)
    local controller = {
      dao = ConferenceDao:new(connection),
      articleDao = ArticleDao:new(connection),
    }
    setmetatable(controller, {__index = self.metatable})
    return controller
  end,
}

M.metatable = {
  --[[
  Responsabilidade: Método para a rota principal da página de conferência
  Pré-Condição: * Deve receber parametros da rota
  Pós-Condição: * Retorna a página html renderizada contendo as conferências e se o usuário é admin ou não
  ]]
  index = function(self, params)
    local conferences = self.dao:all(params.query)
    local auth = Authentication:new(params.cookie)

    return view.render("conferences.html.elua", {args = {
      conferences = ConferenceSerializer:serialize_many(conferences),
      query = params.query,
      is_admin = auth:is_signedin(),
    }})
  end,

  --[[
  Responsabilidade: Método para a rota de criação de conferência
  Pré-Condição: * Deve receber parametros da rota (dados de conferências)
  Pós-Condição: * Cria conferência
                * Retorna a página html contendo as conferências, incluindo a nova
  ]]
  create = function(self, params)
    params.editors = utils.split(params.editors, "[^,]+")

    local conference = Conference:new(params)
    conference = self.dao:insert(conference)

    return view.redirect_to("/conferences.html")
  end,

  --[[
  Responsabilidade: Método para a rota de atualização de conferência
  Pré-Condição: * Deve receber parametros da rota (dados de conferências a serem atualiados)
  Pós-Condição: * Atualiza conferência
                * Retorna a página html contendo as conferências, incluindo conferências com os dados atualizados
  ]]
  update = function(self, params)
    local conference = self.dao:update(Conference:new(params))
    if conference then
      return view.redirect_to("/conferences.html")
    else
      return view.render("not_found.html.elua", {status = 404})
    end
  end,

  --[[
  Responsabilidade: Método para a rota de remoção de conferência
  Pré-Condição: * Deve receber parametros da rota (id da conferência)
  Pós-Condição: * Remove conferência
                * Retorna a página html contendo as conferências
  ]]
  destroy = function(self, params)
    if self.dao:delete(params.id) then
      return view.redirect_to("/conferences.html")
    else
      return view.render("not_found.html.elua", {status = 404})
    end
  end,

  --[[
  Responsabilidade: Método para a rota de exibição uma de conferência específica
  Pré-Condição: * Deve receber parametros da rota (id da conferência)
  Pós-Condição: * Retorna a página html contendo as informações da conferência especificada
  ]]
  show = function(self, params)
    local conference = self.dao:find(params.id)
    local auth = Authentication:new(params.cookie)
    local articles = self.articleDao:all_on_conference(conference.id)
    conference.articles = articles

    if conference then
      return view.render("conference.html.elua", {args = {
        conference = ConferenceSerializer:serialize_one(conference),
        articles = ArticleSerializer:serialize_many(articles),
        is_admin = auth:is_signedin(),
      }})
    else
      return view.render("not_found.html.elua", {status = 404})
    end
  end,
}

return M
